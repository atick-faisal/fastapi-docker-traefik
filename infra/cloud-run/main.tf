# Configure Terraform and required providers
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required Google Cloud APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "iamcredentials.googleapis.com",
    "iam.googleapis.com"
  ])

  service = each.value
  project = var.project_id

  disable_dependent_services = false
  disable_on_destroy         = false

  timeouts {
    create = "30m"
    update = "40m"
  }
}

# Create service account for GitHub Actions
resource "google_service_account" "github_sa" {
  account_id   = var.service_account_id
  display_name = "Service Account for GitHub Actions"
  description  = "Service account used by GitHub Actions for CI/CD operations"
  project      = var.project_id

  depends_on = [google_project_service.apis]
}

# Local values for better code organization
locals {
  service_account_email = google_service_account.github_sa.email

  # Define IAM roles in a map for better maintainability
  iam_roles = {
    "run_admin"        = "roles/run.admin"
    "artifact_writer"  = "roles/artifactregistry.writer"
    "sa_user"         = "roles/iam.serviceAccountUser"
    "storage_admin"   = "roles/storage.admin"  # Often needed for Cloud Run deployments
  }
}

# Assign IAM roles to the service account
resource "google_project_iam_member" "github_sa_roles" {
  for_each = local.iam_roles

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${local.service_account_email}"

  depends_on = [google_service_account.github_sa]
}

# Create Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = var.wip_name
  display_name              = "GitHub Actions WIP"
  description               = "Workload Identity Pool for GitHub Actions CI/CD"
  project                   = var.project_id
  disabled                  = false

  depends_on = [google_project_service.apis]
}

# Create Workload Identity Pool Provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wip_oidc_name
  display_name                       = "GitHub OIDC Provider"
  description                        = "OIDC provider for GitHub Actions authentication"
  project                           = var.project_id
  disabled                          = false

  # Enhanced attribute mapping with additional useful attributes
  attribute_mapping = {
    "google.subject"                = "assertion.sub"
    "attribute.actor"               = "assertion.actor"
    "attribute.repository"          = "assertion.repository"
    "attribute.repository_owner"    = "assertion.repository_owner"
    "attribute.ref"                 = "assertion.ref"
    "attribute.sha"                 = "assertion.sha"
    "attribute.workflow"            = "assertion.workflow"
    "attribute.job_workflow_ref"    = "assertion.job_workflow_ref"
  }

  # More restrictive attribute condition for better security
  attribute_condition = join(" && ", [
    "assertion.repository_owner == '${var.github_repo_owner}'",
    "assertion.repository == '${var.github_repo}'",
    # Optional: Restrict to specific branches or tags
    # "attribute.ref.startsWith('refs/heads/main') || attribute.ref.startsWith('refs/tags/')",
  ])

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
    # Optional: Add allowed audiences for enhanced security
    # allowed_audiences = ["https://github.com/${var.github_repo_owner}"]
  }
}

# Bind the service account to the Workload Identity Pool
resource "google_service_account_iam_binding" "wip_binding" {
  service_account_id = google_service_account.github_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
  ]

  depends_on = [
    google_iam_workload_identity_pool_provider.github_provider,
    google_service_account.github_sa
  ]
}

# Create Artifact Registry repository
resource "google_artifact_registry_repository" "gar" {
  location      = var.region
  repository_id = var.gar_repo_name
  format        = "DOCKER"
  description   = "Container images for GitHub Actions CI/CD pipeline"
  project       = var.project_id

  # Configure cleanup policies
  cleanup_policy_dry_run = false

  # Delete old main-* tagged images (from CI builds)
  cleanup_policies {
    id     = "delete-old-main-builds"
    action = "DELETE"

    condition {
      tag_state    = "TAGGED"
      tag_prefixes = ["main-"]     # Matches your main-a1b2c3d tags
      older_than   = "1209600s"    # 14 days (shorter for CI builds)
    }
  }

  # Keep recent untagged images (intermediate layers, etc.)
  cleanup_policies {
    id     = "keep-recent-untagged"
    action = "KEEP"

    most_recent_versions {
      keep_count = 10
    }
  }

  # Keep latest tag indefinitely (exclude from cleanup)
  cleanup_policies {
    id     = "preserve-latest"
    action = "KEEP"

    condition {
      tag_state = "TAGGED"
      tag_prefixes = ["latest"]
    }
  }

  depends_on = [google_project_service.apis]
}

# Outputs with improved descriptions
output "service_account_email" {
  description = "Email address of the GitHub Actions service account"
  value       = google_service_account.github_sa.email
}

output "workload_identity_pool_id" {
  description = "Full resource name of the Workload Identity Pool"
  value       = google_iam_workload_identity_pool.github_pool.name
}

output "workload_identity_provider_id" {
  description = "Full resource name of the Workload Identity Pool Provider"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository details"
  value = {
    name         = google_artifact_registry_repository.gar.name
    repository_id = google_artifact_registry_repository.gar.repository_id
    location     = google_artifact_registry_repository.gar.location
    format       = google_artifact_registry_repository.gar.format
  }
}

output "docker_repository_url" {
  description = "Full Docker repository URL for pushing images"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.gar.repository_id}"
}
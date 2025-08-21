provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"
}

resource "google_project_service" "iamcredentials_api" {
  service = "iamcredentials.googleapis.com"
}

resource "google_service_account" "github_sa" {
  account_id   = var.service_account_id
  display_name = "Service Account for GitHub Actions"
}

locals {
  service_account_email = google_service_account.github_sa.email
}

resource "google_project_iam_member" "run_admin" {
  role    = "roles/run.admin"
  member  = "serviceAccount:${local.service_account_email}"
  project = var.project_id
}

resource "google_project_iam_member" "artifact_writer" {
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${local.service_account_email}"
  project = var.project_id
}

resource "google_project_iam_member" "sa_user" {
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${local.service_account_email}"
  project = var.project_id
}

resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = var.wip_name
  display_name              = "GitHub WIP"
  description               = "Workload Identity Pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wip_oidc_name
  display_name                       = "GitHub Identity Provider"
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  attribute_condition = "assertion.repository_owner == '${var.github_repo_owner}'"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_binding" "wip_binding" {
  service_account_id = google_service_account.github_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo_owner}/${var.github_repo}"
  ]
}

output "GCP_SERVICE_ACCOUNT" {
  value = google_service_account.github_sa.email
}

output "WIP_ID" {
  value = google_iam_workload_identity_pool.github_pool.name
}

output "WIP_OIDC_ID" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}

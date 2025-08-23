variable "project_id" {
  description = "The Google Cloud Project ID where resources will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "The Google Cloud region where regional resources will be created (e.g., us-central1, europe-west1)"
  type        = string
  default     = "us-central1"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))
    error_message = "Region must be a valid Google Cloud region format (e.g., us-central1, europe-west1)."
  }
}

variable "github_repo" {
  description = "The name of the GitHub repository (without owner prefix)"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9._-]+$", var.github_repo))
    error_message = "GitHub repository name can only contain alphanumeric characters, periods, hyphens, and underscores."
  }
}

variable "github_repo_owner" {
  description = "The GitHub username or organization that owns the repository"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.github_repo_owner))
    error_message = "GitHub repository owner must be a valid GitHub username or organization name."
  }
}

variable "service_account_id" {
  description = "The unique identifier for the Google Cloud service account (must be 6-30 characters, lowercase letters, numbers, and hyphens)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.service_account_id))
    error_message = "Service account ID must be 6-30 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "wip_name" {
  description = "The name of the Workload Identity Pool for GitHub Actions authentication"
  type        = string

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]*[a-z0-9])?$", var.wip_name))
    error_message = "Workload Identity Pool name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "wip_oidc_name" {
  description = "The name of the OIDC identity provider within the Workload Identity Pool for GitHub Actions"
  type        = string

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]*[a-z0-9])?$", var.wip_oidc_name))
    error_message = "OIDC provider name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "gar_repo_name" {
  description = "The name of the Google Artifact Registry repository for storing container images"
  type        = string

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]*[a-z0-9])?$", var.gar_repo_name))
    error_message = "Artifact Registry repository name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}
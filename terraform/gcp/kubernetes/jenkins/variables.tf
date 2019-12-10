variable "image_url" {}
variable "service_name" {}
variable "dns_zone_name" {}
variable "dns_name" {}

data "google_container_registry_repository" "main" {}

locals {
  service_account_key_name_in_secret = "push_rollout_key.json"
}

resource "random_string" "random" {
  length = 64
  special = true
}

variable "gcp_project" {}

variable "app_source_repo" {}
variable "app_image_name" {}
variable "app_service_name" {}
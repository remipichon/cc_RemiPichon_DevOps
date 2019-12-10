variable "image_name" {}
variable "service_name" {}
variable "dns_zone_name" {}
variable "dns_name" {}

data "google_container_registry_repository" "main" {}

locals {
  gcr_url = data.google_container_registry_repository.main.repository_url
}

resource "random_string" "random" {
  length = 64
  special = true
}

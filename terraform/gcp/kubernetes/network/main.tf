variable "dns_zone_name" {}
variable "zone_name" {}

resource "google_dns_managed_zone" "main_public_zone" {
  name        = "${var.zone_name}"
  dns_name    = "${var.dns_zone_name}"
}

output "dns_zone_name" {
  value = "${google_dns_managed_zone.main_public_zone.name}"
}
output "dns_name" {
  value = "${google_dns_managed_zone.main_public_zone.dns_name}"
}

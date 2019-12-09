resource "google_dns_managed_zone" "main_public_zone" {
  name        = "main-public-zone"
  dns_name    = "remipichon.com."
}

output "dns_zone_name" {
  value = "${google_dns_managed_zone.main_public_zone.name}"
}
output "dns_name" {
  value = "${google_dns_managed_zone.main_public_zone.dns_name}"
}

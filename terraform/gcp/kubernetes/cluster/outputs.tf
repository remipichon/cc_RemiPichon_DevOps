output "client_certificate" {
  value     = "${google_container_cluster.cluster.master_auth.0.client_certificate}"
  sensitive = true
}

output "client_key" {
  value     = "${google_container_cluster.cluster.master_auth.0.client_key}"
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = "${google_container_cluster.cluster.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

output "host" {
  value     = "${google_container_cluster.cluster.endpoint}"
  sensitive = true
}

output "username" {
  value = "${var.cluster_name}"
}

output "password" {
  value = "${random_string.random.result}"
}

output "cluster" {
  value = "${google_container_cluster.cluster}"
}

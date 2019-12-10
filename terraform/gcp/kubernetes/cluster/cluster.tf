resource "google_container_cluster" "cluster" {
  name               = "${var.cluster_name}"
  initial_node_count = 1

  addons_config {
    network_policy_config {
      disabled = true
    }
  }

  master_auth {
    username = "masterk8s"
    password = "${random_string.random.result}"
  }

  node_config {
    disk_size_gb = 50
    machine_type = "g1-small"
    preemptible = true
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "random_string" "random" {
  length = 64
  special = true
}


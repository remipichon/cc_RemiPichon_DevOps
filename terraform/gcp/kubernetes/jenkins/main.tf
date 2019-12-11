resource "kubernetes_replication_controller" "jenkins" {
  metadata {
    name = "${var.service_name}"

    labels = {
      app  = "${var.service_name}"
      tier = "jenkins"
    }
  }

  spec {
    replicas = 1

    selector = {
      app  = "${var.service_name}"
      tier = "frontend"
    }

    template {
      volume {
        name = "google-cloud-key"
        secret {
          secret_name = "${kubernetes_secret.example.metadata[0].name}"
        }
      }

      container {
        image = "${var.image_url}"
        name  = "${var.service_name}-jenkins"

        port {
          container_port = 8080
        }

        security_context {
          privileged = true
        }

        volume_mount {
          mount_path = "/var/secrets/google"
          name = "google-cloud-key"
        }

        env {
          name = "GOOGLE_APPLICATION_CREDENTIALS"
          value = "/var/secrets/google/${local.service_account_key_name_in_secret}"
        }

        env {
          name = "JENKINS_ADMIN_PASS"
          value = "${random_string.random.result}"
        }

        env {
          name = "GCP_PROJECT"
          value = "${var.gcp_project}"
        }

        env {
          name = "DEPLOY_TARGET"
          value = "gcp"
        }

        env {
          name = "APP_SOURCE_REPO"
          value = "${var.app_source_repo}"
        }

        env {
          name = "CLUSTER_NAME"
          value = "${var.cluster_name}"
        }

        env {
          name = "ZONE"
          value = "${var.cluster_zone}"
        }

        env {
          name = "APP_IMAGE_NAME"
          value = "${var.app_image_name}"
        }

        env {
          name = "APP_SERVICE_NAME"
          value = "${var.app_service_name}"
        }

        resources {
          requests {
            cpu    = "100m"
            memory = "100Mi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jenkins" {
  metadata {
    name = "${var.service_name}"

    labels = {
      app  = "${var.service_name}"
      tier = "jenkins"
    }
  }

  spec {
    selector = {
      app  = "${var.service_name}"
      tier = "frontend"
    }

    type = "LoadBalancer"

    port {
      port = 80
      target_port = 8080
    }
  }
}


resource "google_dns_record_set" "jenkins" {
  name = "${var.service_name}.${var.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"

  rrdatas = ["${kubernetes_service.jenkins.load_balancer_ingress[0].ip}"]
}

output "endpoint" {
  value = "${kubernetes_service.jenkins.load_balancer_ingress[0].ip}"
}

resource "kubernetes_replication_controller" "api" {
  metadata {
    name = "${var.service_name}"

    labels = {
      app  = "${var.service_name}"
      tier = "api"
    }
  }

  lifecycle {
    //spec.selector.deployment is updated by K8s when doing a rolling update
    ignore_changes = ["spec[0].selector"]
  }

  spec {
    replicas = 1

    selector = {
      app  = "${var.service_name}"
      tier = "frontend"
    }

    template {
      container {
        image = "${local.gcr_url}/${var.image_name}"
        name  = "${var.service_name}-api"

        port {
          container_port = 3000
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

resource "kubernetes_service" "api" {
  metadata {
    name = "${var.service_name}"

    labels = {
      app  = "${var.service_name}"
      tier = "api"
    }
  }

  spec {
    selector = {
      app  = "${var.service_name}"
      tier = "frontend"
    }

    type = "LoadBalancer"

    port {
      target_port = 3000
      port = 80
    }
  }
}


resource "google_dns_record_set" "api" {
  name = "${var.service_name}.${var.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"

  rrdatas = ["${kubernetes_service.api.load_balancer_ingress[0].ip}"]
}

output "endpoint" {
  value = "${kubernetes_service.api.load_balancer_ingress[0].ip}"
}

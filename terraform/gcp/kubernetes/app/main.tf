resource "kubernetes_replication_controller" "api" {
  metadata {
    name = "${var.service_name}"

    labels = {
      app  = "${var.service_name}"
      tier = "api"
    }
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

//TODO https
resource "kubernetes_ingress" "example_ingress" {
  metadata {
    name = "api-api-ingress"
  }

  spec {
    backend {
      service_name = "${var.service_name}"
      service_port = "80"
    }

//    tls {
//      secret_name = "tls-secret"
//    }
  }
}

resource "google_compute_managed_ssl_certificate" "main" {
  provider = google-beta

  name = "app-api-cert"

  managed {
    domains = ["${var.service_name}.${var.dns_name}"]
  }
}

module "network" {
  source = "./network"

  dns_zone_name = "${var.dns_zone_name}"
  zone_name = "main-public-zone"
}

module "cluster" {
  source = "./cluster"

  cluster_name = "main-cluster"
}

module "jenkins" {
  source = "./jenkins"

  dns_zone_name = "${module.network.dns_zone_name}"
  dns_name = "${module.network.dns_name}"
  service_name = "jenkins"
  image_url = "remipichon/assignment-jenkins"

  gcp_project = "${var.project}"
  app_service_name = "${var.application_service_name}"
  app_source_repo = "${var.app_repo}"
  app_image_name = "${var.application_image_name}"
  cluster_name = "${module.cluster.cluster.name}"
  cluster_zone = "${module.cluster.cluster.zone}"
}

module "app_api" {
  source = "./app"

  dns_zone_name = "${module.network.dns_zone_name}"
  dns_name = "${module.network.dns_name}"
  service_name = "${var.application_service_name}"
  image_name = "${var.application_image_name}"
}

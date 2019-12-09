module "network" {
  source = "./network"
}

module "cluster" {
  source = "./cluster"

  cluster_name = "main-cluster"
}

module "app_api" {
  source = "./app"

  dns_zone_name = "${module.network.dns_zone_name}"
  dns_name = "${module.network.dns_name}"
  service_name = "jenkins"
  image_name = "jenkins"
}

module "jenkins" {
  source = "./jenkins"

  dns_zone_name = "${module.network.dns_zone_name}"
  dns_name = "${module.network.dns_name}"
  service_name = "api"
  image_name = "app_api"
}

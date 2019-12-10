module "network" {
  source = "./network"
}

module "cluster" {
  source = "./cluster"

  cluster_name = "main-cluster"
}

//TODO network and cluster in a separate root module

//app in another one

//jenkins in another on



module "app_api" {
  source = "./app"

  dns_zone_name = "${module.network.dns_zone_name}"
  dns_name = "${module.network.dns_name}"
  service_name = "api"
  image_name = "app_api"
}

module "jenkins" {
  source = "./jenkins"

  dns_zone_name = "${module.network.dns_zone_name}"
  dns_name = "${module.network.dns_name}"
  service_name = "jenkins"
  image_name = "jenkins"
  app_repo = "${var.app_repo}"
  gcp_project = "${var.project}"
}

output "jenkins_admin_pass" {
  value = "${module.jenkins.jenkins_admin_pass}"
}


//via VM -m)x:fK(rBKcu^7C
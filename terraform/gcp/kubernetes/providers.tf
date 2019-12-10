provider "kubernetes" {
  host     = "${module.cluster.host}"

  client_certificate     = "${base64decode(module.cluster.client_certificate)}"
  client_key             = "${base64decode(module.cluster.client_key)}"
  cluster_ca_certificate = "${base64decode(module.cluster.cluster_ca_certificate)}"
}

provider "google" {
  project     = "${var.project}"
  region = "${var.region}"
  zone   = "${var.zone}"
}

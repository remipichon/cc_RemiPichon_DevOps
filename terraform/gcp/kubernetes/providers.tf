provider "kubernetes" {
  host     = "${module.cluster.host}"

  client_certificate     = "${base64decode(module.cluster.client_certificate)}"
  client_key             = "${base64decode(module.cluster.client_key)}"
  cluster_ca_certificate = "${base64decode(module.cluster.cluster_ca_certificate)}"
}

//create project from console
provider "google" {
  //TODO read that from env or conf
  project     = "zenhubviaconsole"
  region      = "europe-west1"
  zone      = "europe-west1-b"
}


provider "google-beta" {
  //TODO read that from env or conf
  project     = "zenhubviaconsole"
  region = "us-central1"
  zone   = "us-central1-a"
}
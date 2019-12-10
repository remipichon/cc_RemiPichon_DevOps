//resource "google_service_account" "jenkins" {
//  account_id = "jenkins_push_rollout"
//}
//
//resource "google_service_account_key" "mykey" {
//  service_account_id = google_service_account.myaccount.name
//}
//
//data "google_service_account_key" "mykey" {
//  name            = google_service_account_key.mykey.name
//  public_key_type = "TYPE_X509_PEM_FILE"
//}

//store that key in a k8s secret
//resource "kubernetes_secret" "example" {
//  metadata {
//    name = "basic-auth"
//  }
//
//  data = {
//    username = "admin"
//    password = "P4ssw0rd"
//  }
//
//  type = "kubernetes.io/basic-auth"
//}



//kubectl create secret generic pubsub-key --from-file=zenhub_travis_key.json
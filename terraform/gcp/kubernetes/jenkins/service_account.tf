resource "google_service_account" "push_rollout" {
  account_id = "${var.service_name}pushrollout"
  display_name = "${var.service_name}_push_rollout"
  description = "${var.service_name} access to GCR (push) and K8s (rollout-update)"
}

//couldn't add the right role...
//resource "google_service_account_iam_binding" "admin-account-iam" {
//  service_account_id = "${google_service_account.push_rollout.name}"
//  role = "roles/container.admin"
//
//  members = ["serviceAccount:${google_service_account.push_rollout.email}"]
//}

resource "google_service_account_key" "push_rollout" {
  service_account_id = "${google_service_account.push_rollout.name}"
}

data "google_service_account_key" "push_rollout" {
  name = "${google_service_account_key.push_rollout.name}"
  public_key_type = "TYPE_X509_PEM_FILE"
}

resource "kubernetes_secret" "example" {
  metadata {
    name = "${var.service_name}-push-rollout-key"
  }
  type = "Opaque"

  data = {
    "${local.service_account_key_name_in_secret}" = "${data.google_service_account_key.push_rollout.public_key}"
  }
}

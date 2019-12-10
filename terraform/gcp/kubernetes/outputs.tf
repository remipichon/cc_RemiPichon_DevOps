output "jenkins_admin_pass" {
  value = "${module.jenkins.jenkins_admin_pass}"
}

output "jenkins_public_ip" {
  value = "${module.jenkins.endpoint}"
}

output "app_public_ip" {
  value = "${module.app_api.endpoint}"
}
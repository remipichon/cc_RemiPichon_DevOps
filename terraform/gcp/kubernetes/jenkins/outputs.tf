output "jenkins_admin_pass" {
  value = "${random_string.random.result}"
}
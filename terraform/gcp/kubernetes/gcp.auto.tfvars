# should be created before hand via the console
project = "zenhubviaconsole"
# where the Kubernets cluster will be created
region = "europe-west3"
zone = "europe-west3-a"
# the repository holding the app code (under the app directory), should be public
app_repo = "https://github.com/remipichon/cc_RemiPichon_DevOps.git"
# the public Dns zone to create records
dns_zone_name = "remipichon.com."
# name of the app to deploy, will be used to generate K8s ressources (replication group, service) and DNS route for public access
application_service_name = "api"
# name of the Docker image to build and push to GCR
application_image_name = "api"

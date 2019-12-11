ZenHub DevOps Test
-------------------------

## Purpose
This exercise is meant to be a relatively straightforward deployment for a fictional REST API application. 

## Included Resources
You should have read access to the `github.com/axiomzen/zenhub-devops-interview`.  Within this repository is a simple `node.js` REST API hello world. You should fork this repository and make all of your code edits there within a feature branch.

You also have access to us! Feel free to e-mail us with any questions you have about the application, the process, clarification or whatever you like. Generally we would run through this exercise in person, and we would like you to feel as though you’ve got access to the team the same as if you were here running through it with us! 

If you run into any issues throughout the process, please reach out to devops@zenhub.com

## OK, so what are we expecting you to do with this?
Ultimately we want to see the application fully deployed, meaning we would like to see automated deployments of the containerized application.

Here is a breakdown of a few things that we would like to see:

1) Containerize the API app using `Docker` 
- You may use any `node.js` version for this app. 
- The API is runs on port `3000` 
- Bonus points if you deploy it using Docker Swarm

2) We use `Jenkins` to deploy the application through a series of tasks 
- The task itself will pull from version control (i.e. `git`) for new changes and deploys the app
- If you have not used `Jenkins` before that's OK! You can use other tools that you are more familiar with to deploy this! However you must be able to pull from upstream for new changes.

3) Using `Vagrant` to deploy your application to 
- We provided the skeleton of the Vagrant file that you can use
- You will need to install `Docker` and `Jenkins` yourself (or whatever additional tools that you need). Remember to add them to your `Vagrantfile`!

We are going to make the assumption that you are aware of some of the other facets of operations, and we are not asking or expecting you to implement any monitoring, alerting, or that kind of thing into the exercise. It would be _extremely_ helpful for us while you are going through the exercise to document your thought process and what you are planning, or the types of things you’d take into account if this were a production application.

Again, please don't hesitate to reach out to the team at devops@zenhub.com with any questions.  Good luck!



My solution
===========================

# Getting Started

## Vagrant (local)

* install Vagrant
* install VirtualBox

```
vagrant up
```

You will have a Vagrant based on Ubuntu with
* Docker and Docker Swarm cluster enabled
* Jenkins available on port 8080 (localhost:8080) 
  * user is **admin/adminp@ass**
  * there is ready to use "build_push_deploy_api" to build the app (in app director) and deploy it to Docker Swarm
* once deployed the Hello World app is available at localhost:3000

> port 3000 and 8080 should be available on the host for Vagrant to bind

> building Jenkins can take time, especially on bad internet... (pull Jenkins image, download Docker daemon, download Gcloud and Kubectl)
  
### Under the hood

Vagrant uses Ansible playbooks to
* install Docker and setup a Docker Swarm cluster with a single master node
* locally build a custom Jenkins (in jenkins directory) and deploy it to the Docker Swarm

The custom Jenkins features:
* create an admin user at startup
* Docker client using the Daemon available on the host (Vagrant) to build and push Docker image and deploy Docker Stack
* create at startup a preconfigured CD pipeline which
    * clone "https://github.com/remipichon/cc_RemiPichon_DevOps"
    * build the app (under app directory) using Docker
    * push the app to the local registry (a Docker Registry running on Swarm)
    * deploy/update the Docker Stack running the app


  
## Terraform (Google Compute Platform)  

* install Terraform (0.12+)
* configure your GCP credentials
* create a project in GCP 
* edit the file _gcp.auto.tfvars_, see the file for more details
    * if you don't own a DNS zone, just typa a farly large random string to allow the process to go through
    * if you do own a DNS zone, you will have to copy the DNS server records to your DNS provider for the public records
    to work

```
cd terraform/gcp/kubernetes
terraform init
terraform plan -out k8s.plan
terraform apply k8s.plan
```

It will provision on GCP
* a Kubernetes cluster with one very smoll node
* a replication controller + service + dns records for Jenkins
* a replication controller + service + dns records for the App api

If the DNS zone you provided is working (you own it, configured the Google DNS server records and waited for the DNS propagation)
then Jenkins is available at `http://jenkins.<DNSzone>` and once deployed the app will be available at `http://<application_service_name>.<DNSzone>`.

If the DNS zone is not working for you, you can find the K8s service public ips with
```
terraform output jenkins_ip
terraform output app_ip
```

> Jenkins and the app are running on port 80, there is no HTTPS


### Under the hood

Terraform is used to create all the Google Cloud Platform resources. The app and Jenkins are running in Docker like in
the Vagrant installation but are orchestrated by Kubernetes instead of Swarm. 

The custom Jenkins is the same as the one used in Vagrant, please note that it also has
* gcloud, the GCP CLI
* kubectl, the Kubernets CLI
* Docker Daemon fully setup

> We cannot use the Docker socket and rely on the Docker daemon from the host while running on Kubernetes. Instead, the
Jenkins container run in "privileged" mode use a Docker daemon in Docker. 


The pipeline is configured via environment variables, injected in the container. The _DEPLOY_TARGET_ allows to switch 
between GCP and Swarm. Terraform deploys Jenkins configured for GCP, the only differences are
* push the app the Google Container Registry
* perform a rollout update on the app application controller (the one created by Terraform)

> Because the app Docker image is not present on GCR when you terraform apply for the first time, the app replication 
controller will fails to work. You should trigger the "build_push_deploy_api" Jenkins Pipeline at least once

For the convenience, the custom Jenkins app has been pushed to the public Docker Registry at 'remipichon/assignment-jenkins' 
and used in Kubernetes to deploy Jenkins. If you wish to work on the custom Jenkins pleace build and push to GCR with
```
cd jenkins
docker build -t gcr.io/zenhubviaconsole/jenkins .
gcloud auth configure-docker
docker push gcr.io/zenhubviaconsole/jenkins 
```
and update the attribute __image_url__ for the module __jenkins__ in the file "terraform/gcp/kubernetes/main.tf" then
```
terraform plan
terraform apply
kubectl rolling-update jenkins --image gcr.io/<your_project>/jenkins --image-pull-policy Always
```

> running the rolling update would be enough to use the new image, wep, that's a flaw, Terraform is not the only source 
of truth


## Going Forward

There are a few goals to look into before making that CI/CD production ready. 

The *Vagrant* should deal with a real Swarm Cluster made a several nodes running on other VMs provisioned via Vagrant. 
Ansible could be an easy tool to manage such different VMs type.

Several small improvements on the *Jenkins* image should be considered:
* instead of just an admin user, create some visitor/developer users with read/run access on specific pipeline
* setup a Git release policy to tag Docker images
* a more generic configuration to allow creating several pipelines for multiple other apps. The pipeline being generated
at runtime, it's only a matter of having some usages
* use Jenkins to build and deploy itself

The *GCP* provisioning could be better, it is my first time using Google Cloud, I could not manage everything nicely:
* provide HTTPS via K8s Ingress with Google Managed Certificate to automate the HTTPS process
* proper network setup with isolation (Jenkins not public for example)
* use a properly setup Service Account with minimum role to allow only Jenkins K8s Replication Group to have programmatic
  access to the Container Cluster (with current configuration, the whole Cluster Node has programmatic access via   
  the auth scope "https://www.googleapis.com/auth/cloud-platform")
* provider persistent storage for Jenkins (the /var/jenkins_home) which is a volume in the Swarm installation

The *Terraform* code is made to be easy to apply once, a more fragmented implementation could benefit developments phases:
* an __infra__ root module for the network stack and the Kubernetes Cluster
* a __tools__ root module for Jenkins
* an __app__ root module, will, for the app
Also, an easy task would be to setup a remote backend to securely store the state on on GCP 


The *app* could use a health check to help deployment (rolling update waits for healthiness)


# sandbox

Build and ship
```
docker build -t gcr.io/zenhubviaconsole/jenkins .
docker push gcr.io/zenhubviaconsole/jenkins 
 
docker build -t remipichon/assignment-jenkins .
docker push remipichon/assignment-jenkins
 
```

Test Cmd on Jenkins
```
cmd = "kubectl rolling-update api --image gcr.io/zenhubviaconsole/app_api"
//cmd = "kubectl config current-context"
//cmd = "gcloud container clusters get-credentials main-cluster --zone us-central1-a	"

//cmd = "service docker start"
//cmd = "docker ps"
cmd = "gcloud auth configure-docker"

def sout = new StringBuilder(), serr = new StringBuilder()
def proc = cmd.execute()
proc.consumeProcessOutput(sout, serr)
proc.waitForOrKill(10000)
println "out> $sout err> $serr"
```

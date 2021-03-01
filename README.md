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

My solution is made of two parts:
* one indented to run on a local VM provisioned by Vagrant where Jenkins runs on Docker Swarm, the app is deployed on Swarm
* one made for Google Cloud where Jenkins is deployed on Kubernetes Engine, the app being deployed on Kubernetes as well

# Getting Started

## Vagrant (local)

> Provision a Vagrant with Jenkins and Docker Swarm

Prerequisites:
* install Vagrant
* install VirtualBox

```
vagrant up
```

You will end up with Vagrant VM based on Ubuntu with:
* Docker with Docker Swarm cluster enabled
* Jenkins available on port 8080 (localhost:8080), it features 
  * an admin user with username **admin** and password **adminp@ss**
  * a ready to use _build_push_deploy_api_ to build the app (which is in `app` director) and deploy it to Docker Swarm
* once deployed the Hello World app is available at localhost:3000

> port 3000 and 8080 should be available on the host for Vagrant to bind them

> building Jenkins can take time, especially on bad internet... (pull Jenkins image, download Docker daemon, download Gcloud and Kubectl)
  
### Under the hood

Vagrant uses Ansible playbooks to :
* install Docker and setup a Docker Swarm cluster with a single master node
* locally build a custom Jenkins (which is in `jenkins` directory) and deploy it to the Docker Swarm

The custom Jenkins features:
* create an admin user at startup
* Docker client using the Daemon available on the host (Vagrant) to build Docker image and deploy Docker Stacks
* a preconfigured CD pipeline, created at startup, which:
    * clone _https://github.com/remipichon/cc_RemiPichon_DevOps_
    * build the app (under `app` directory) using Docker
    * push the app to the local registry (a Docker Registry running on Swarm)
    * deploy/update the Docker Stack running the app
 
> this setup in not intended to be use on public instances as the Jenkins password is kinda weak. You can update it in
_ansible/deploy_jenkins.yml_, the env _JENKINS_ADMIN_PASS_ in the last task
   
## Terraform (Google Compute Platform)

> Provision a Kubernetes cluster to deploy Jenkins and the app and make them publicly available 

Prerequisites:
* install Terraform (0.12+)
* configure your GCP credentials
* create a project in GCP 
* edit the file _gcp.auto.tfvars_, see the file for more details
    * if you don't own a DNS zone, just type a farly large random string to allow the process to go through
    * if you do own a DNS zone, you will have to copy the DNS server records to your DNS provider for the public records
    to work

```
cd terraform/gcp/kubernetes
terraform init
terraform plan -out k8s.plan
terraform apply k8s.plan
```

It will provision on GCP:
* a Kubernetes cluster with one very smoll node (smallest available)
* a replication controller + service + dns records for Jenkins
* a replication controller + service + dns records for the App api

If the DNS zone you provided is working (you own it, configured the Google DNS server records and waited for the DNS propagation)
then Jenkins is available at __http://jenkins.{DNSzone}__ and once deployed the app will be available at __http://{application_service_name}.{DNSzone}__.

If the DNS zone is not working for you, you can find the K8s service public ips with
```
terraform output jenkins_ip
terraform output app_ip
```

> Jenkins and the app are running on port 80, there is no HTTPS

> It would cost about $30-40 per month, you can remove all the resources with `terraform destroy`


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
between _gcp_ and _swarm_. Terraform deploys Jenkins configured for GCP, the only differences with the one deployed by 
Ansible in Vagrant are: 
* it pushes the app the Google Container Registry
* it performs a rollout update on the app replication controller (the one created by Terraform)

> Because the app Docker image is not present on GCR when you terraform apply for the first time, the app replication 
controller will fail to push the image. You should trigger the _build_push_deploy_api_ Jenkins Pipeline at least once to see
the app live. 

For the convenience, the custom Jenkins app has been pushed to the public Docker Registry at 'remipichon/assignment-jenkins' 
and used in Kubernetes to deploy Jenkins. If you wish to work on the custom Jenkins, you can build it and push it to GCR with
```
cd jenkins
docker build -t gcr.io/<gcp_project>/jenkins .
gcloud auth configure-docker
docker push gcr.io/<gcp_project>/jenkins 
```
and update the attribute __image_url__ for the __jenkins__ module in the file _terraform/gcp/kubernetes/main.tf_ then
```
terraform plan
terraform apply
kubectl rolling-update jenkins --image gcr.io/<your_project>/jenkins --image-pull-policy Always
```

> running the rolling update would be enough to use the new image, wep, that's a flaw, Terraform is not the only source 
of truth in that case


## Going Forward

There are a few goals to look into before making that CI/CD production ready. 

The **Vagrant** should deal with a real Swarm Cluster made of several nodes running on other VMs provisioned via Vagrant. 
Ansible could be a convenient tool to manage such cluster as there is already a Swarm module to manage a cluster. 

Several small improvements on the **Jenkins** image should be considered:
* instead of just an admin user, create some visitor/developer users with read/run access on specific pipelines
* setup a Git release policy to tag Docker images
* a more generic configuration to allow creating several pipelines for multiple other apps
* use Jenkins to build and deploy itself 

The **GCP** provisioning could be better, it is my first time using Google Cloud, I could not manage everything nicely:
* provide HTTPS via K8s Ingress with Google Managed Certificate to automate the HTTPS process
* proper network setup with isolation (Jenkins not public for example)
* use a properly setup Service Account with minimum role to allow only Jenkins K8s Replication Group to have programmatic
  access to the Container Cluster (with current configuration, the whole Cluster Node has programmatic access via   
  the auth scope _https://www.googleapis.com/auth/cloud-platform_)
* provide persistent storage for Jenkins (the /var/jenkins_home) which is a volume in the Swarm installation and is lost each time
the pods restart in GCP

The **Terraform** code is made to be easy to apply once, a more fragmented implementation could benefit developments phases:
* an _infra_ root module for the network stack and the Kubernetes Cluster
* a _tools_ root module for Jenkins
* an _app_ root module, will, for the app
Also, an easy task would be to setup a remote backend to securely store the state on Google Cloud Storage 

The **app** could use a health check to help deployment (rolling update waits for healthiness)
   
   
   

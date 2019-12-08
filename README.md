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


# Going Forward

* a separate repo for the app from the DevOps tooling (Jenkins, Terraform)


# Getting Started

* install Vagrant
* install VirtualBox

```
VAGRANT_VAGRANTFILE=Vagrantfile.rb vagrant up
VAGRANT_VAGRANTFILE=Vagrantfile.rb vagrant ssh
```
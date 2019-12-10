pipeline {
  parameters {
    choice(
      choices: ['swarm', 'gcp'],
      description: 'Either deploy on Docker Swarm on which Jenkins is running or to Google Cloud',
      name: 'DEPLOY_TARGET'
    )
    //TODO this one should be set by Terraform via env
    string(
      // Jenkins should have all the required permissions to access GCP CLI
      description: 'Google Cloud project name',
      defaultValue: 'zenhubviaconsole',
      name: 'GCP_PROJECT'
    )
    string(
      // Jenkins should have all the required permissions to access GCP CLI
      description: 'required: Application name, used to push <docker_registry>/<APP_NAME> and as Docker Stack name or replicationcontroller name ',
      defaultValue: 'app_api',
      name: 'APP_NAME'
    )
    string(
      description: 'required: Git repository with the application code (in app directory)',
      defaultValue: "https://github.com/remipichon/cc_RemiPichon_DevOps.git",
      name: 'REPO'
    )
  }

  agent any
  stages {
    stage('Checkout source') {
      steps {
        git branch: "master", url: params.REPO
      }
    }

    stage('Build and Push to local Registry') {
      when {
        expression { params.DEPLOY_TARGET == 'swarm' }
      }
      steps {
        dir('app') {
          script {
            docker.withServer('unix:///var/run/docker.sock') {
              def customImage = docker.build("127.0.0.1:5000/" + params.APP_NAME)
              // todo push a revelant tag
              customImage.push()
            }
          }
        }
      }
    }

    stage('Build and Push to Google Cloud Registry') {
      when {
        expression { params.DEPLOY_TARGET == 'gcp' }
      }
      steps {
        sh "gcloud auth configure-docker"
        dir('app') {
          script {
            docker.withServer('unix:///var/run/docker.sock') {
              def customImage = docker.build("gcr.io/" + params.GCP_PROJECT + "/" + params.APP_NAME)
              // todo push a revelant tag
              customImage.push()
            }
          }
        }
      }
    }

    stage('Deploy to local Swarm') {
      when {
        expression { params.DEPLOY_TARGET == 'swarm' }
      }
      steps {
        dir("app") {
          script {
            docker.withServer('unix:///var/run/docker.sock') {
              println("Docker Stack 'app' doesn't exist, creating")
              sh(script: 'docker stack deploy ' + params.APP_NAME + ' --compose-file docker-compose.yml')
            }
          }
        }
      }
    }

    stage('Deploy to Google Cloud') {
      when {
        expression { params.DEPLOY_TARGET == 'gcp' }
      }
      steps {
        sh 'kubectl rollout restart replicationcontrollers/' + params.APP_NAME
      }
    }

  }
}
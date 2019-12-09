pipeline {
  parameters {
    choice(
      choices: ['swarm', 'gpc'],
      description: 'Either deploy on Docker Swarm on which Jenkins is running or to Google Cloud',
      name: 'DEPLOY_TARGET'
    )
    string(
      // Jenkins should have all the required permissions to access GCP CLI
      description: 'Kubernetes Cluster to deploy the app',
      defaultValue: '',
      name: 'GCP_CLUSTER_NAME'
    )
  }

  agent any
  stages {
    stage('Checkout source') {
      steps {
        git branch: "master", url: 'https://github.com/remipichon/cc_RemiPichon_DevOps.git'
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
              def customImage = docker.build("127.0.0.1:5000/app_api")
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
        dir('app') {
          script {
            docker.withServer('unix:///var/run/docker.sock') {
              def customImage = docker.build("????????/app_api")
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
              sh(script: 'docker stack deploy app --compose-file docker-compose.yml')
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
        sh 'echo DEPLOY GCP'
      }
    }

  }
}
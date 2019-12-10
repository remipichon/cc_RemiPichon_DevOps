pipeline {
  parameters {
    //TODO this should be injected via env
    choice(
      choices: ['swarm', 'gcp'],
      description: 'Either deploy on Docker Swarm on which Jenkins is running or to Google Cloud',
      name: 'DEPLOY_TARGET'
    )
    string(
      // Jenkins should have all the required permissions to access GCP CLI
      description: 'required: Application name, used to push <docker_registry>/<APP_NAME> and as Docker Stack name or replicationcontroller name ',
      defaultValue: 'app_api',
      name: 'APP_NAME'
    )
  }

  agent any
  stages {
    stage('Checkout source') {
      steps {
        git branch: "master", url: env.APP_REPO
      }
    }

    stage('Build and Push to local Registry') {
      when {
        expression { params.DEPLOY_TARGET == 'swarm' }
      }
      steps {
        sh "service docker start"
        dir('app') {
          script {
            docker.withServer('unix:///var/run/docker.sock') {
              def customImage = docker.build("127.0.0.1:5000/" + params.APP_NAME)
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
        sh "service docker start"
        sh "gcloud auth configure-docker"
        dir('app') {
          script {
            docker.withServer('unix:///var/run/docker.sock') {
              def customImage = docker.build("gcr.io/" + env.GCP_PROJECT + "/" + params.APP_NAME)
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
        //tODO get zone from env
        sh 'gcloud container clusters get-credentials main-cluster --zone us-central1-a'
        //TODO ci app_name c'est api
        sh 'kubectl rolling-update ' + params.APP_NAME + ' --image-pull-policy Always --image gcr.io/' + env.GCP_PROJECT + "/" + params.APP_NAME
      }
    }

  }
}
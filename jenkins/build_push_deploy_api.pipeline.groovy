pipeline {
  agent any
  stages {
    stage('Checkout source') {
      steps {
        git branch: "master", url: env.APP_SOURCE_REPO
      }
    }

    stage('Build and Push to local Registry') {
      when {
        expression { env.DEPLOY_TARGET == 'swarm' }
      }
      steps {
        sh "service docker start || true" //seems like the pipeline miss-interpret the return code
        dir('app') {
          script {
            docker.withServer('unix:///var/run/docker.sock') {
              def customImage = docker.build("127.0.0.1:5000/" + env.APP_IMAGE_NAME)
              customImage.push()
            }
          }
        }
      }
    }

    stage('Build and Push to Google Cloud Registry') {
      when {
        expression { env.DEPLOY_TARGET == 'gcp' }
      }
      steps {
        sh "service docker start || true" //seems like the pipeline miss-interpret the return code
        sh "gcloud auth configure-docker --quiet"
        dir('app') {
          script {
            docker.withServer('unix:///var/run/docker.sock') {
              def customImage = docker.build("gcr.io/" + env.GCP_PROJECT + "/" + env.APP_IMAGE_NAME)
              customImage.push()
            }
          }
        }
      }
    }

    stage('Deploy to local Swarm') {
      when {
        expression { env.DEPLOY_TARGET == 'swarm' }
      }
      steps {
        dir("app") {
          script {
            docker.withServer('unix:///var/run/docker.sock') {
              println("Docker Stack 'app' doesn't exist, creating")
              sh(script: 'docker stack deploy ' + env.APP_SERVICE_NAME + ' --compose-file docker-compose.yml')
            }
          }
        }
      }
    }

    stage('Deploy to Google Cloud') {
      when {
        expression { env.DEPLOY_TARGET == 'gcp' }
      }
      steps {
        sh 'gcloud container clusters get-credentials '+ env.CLUSTER_NAME +' --zone us-central1-a'
        sh 'kubectl rolling-update ' + env.APP_SERVICE_NAME +
          ' --image-pull-policy Always --image gcr.io/' + env.GCP_PROJECT + "/" + env.APP_IMAGE_NAME
      }
    }

  }
}
FROM jenkins/jenkins:latest

# install plugins
COPY ./jenkins-plugins /usr/share/jenkins/plugins
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins

USER root
# install Docker
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
     	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
			apt-key fingerprint 0EBFCD88 && \
			 add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/debian \
     	$(lsb_release -cs) \
     	stable" && \
  		apt-get update && \
			apt-get install -y docker-ce docker-ce-cli containerd.io
#RUN systemctl enable docker # dont' start the daemon has it is not used when deployed on Vagrant
#RUN usermod -a -G root jenkins
#USER jenkins

# install Google Cloud Cli and Kubectl
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
				apt-get update -y && \
				apt-get install google-cloud-sdk kubectl -y

# skip setup wizard
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false"

# defines users (admin pass has to be overridden is order to be created at runtime)
# all other variable allows to configure Jenkins Pipeline
ENV JENKINS_ADMIN admin
ENV JENKINS_ADMIN_PASS ""
ENV JENKINS_USER ""
ENV JENKINS_USER_PASS ""
ENV DEPLOY_TARGET ""
ENV APP_SOURCE_REPO ""
ENV APP_IMAGE_NAME ""
ENV APP_SERVICE_NAME ""
# GCP only
ENV GCP_PROJECT ""
ENV CLUSTER_NAME ""
ENV ZONE ""

# creating default users
COPY create_user.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY create_pipeline_seeder.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY pipeline_seeder.pipeline.groovy /var/jenkins_home/
COPY build_push_deploy_api.pipeline.groovy /var/jenkins_home/

# Jenkins settings
VOLUME /var/jenkins_home

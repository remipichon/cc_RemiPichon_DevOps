FROM jenkins/jenkins:latest

# install plugins
COPY ./jenkins-plugins /usr/share/jenkins/plugins
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins

USER root
# install Docker CLI (only)
ENV DOCKERVERSION=19.03.5
RUN curl https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz -o docker-${DOCKERVERSION}.tgz \
  && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 -C /usr/local/bin docker/docker \
  && rm docker-${DOCKERVERSION}.tgz
#RUN usermod -a -G root jenkins
#USER jenkins

# skip setup wizard
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false"

# defines users
ENV JENKINS_ADMIN admin
ENV JENKINS_ADMIN_PASS TEST
ENV JENKINS_USER ""
ENV JENKINS_USER_PASS ""

# creating default users
COPY create_user.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY create_pipeline_seeder.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY pipeline_seeder.pipeline /usr/share/jenkins/ref/init.groovy.d/
COPY build_push_deploy_api.pipeline /usr/share/jenkins/ref/init.groovy.d/

# Jenkins settings
VOLUME /var/jenkins_home

FROM jenkins/jenkins:lts

# 80 = nginx
# 8080 = jenkins
# 50000 = jenkins workers
EXPOSE 50000 80

# set a health check to make sure jenkins is working
HEALTHCHECK --interval=5s \
            --timeout=5s \
            CMD curl -f http://127.0.0.1:8080 || exit 1

# Install build tools
USER root

# Copy new entrypoint file
COPY files/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY files/start-jenkins.sh /start-jenkins.sh
RUN chmod +x /start-jenkins.sh

# copy list of plugins
COPY files/plugins.txt /usr/share/jenkins/ref/plugins.txt

# enable logging
COPY files/log.properties /usr/share/jenkins/ref/log.properties

# copy jenkins groovy configuration scripts
COPY files/groovy/*.groovy /usr/share/jenkins/ref/init.groovy.d/

COPY files/config.xml  /usr/share/jenkins/ref/config.xml

# import jobs
COPY jobs/ /usr/share/jenkins/ref/jobs/

# fix permissions
RUN chown -R jenkins:jenkins /usr/share/jenkins/ref

# install nginx
RUN apt-get update
RUN apt-get install -y nginx
COPY files/nginx-jenkins /etc/nginx/sites-enabled/jenkins
RUN rm -rf /etc/nginx/sites-enabled/default

# install docker
ARG DOCKER_CLIENT=docker-17.06.2-ce.tgz

RUN cd /tmp/ \
&& curl -sSL -O https://download.docker.com/linux/static/stable/x86_64/${DOCKER_CLIENT} \
&& tar zxf ${DOCKER_CLIENT} \
&& mkdir -p /usr/local/bin \
&& mv ./docker/docker /usr/local/bin \
&& chmod +x /usr/local/bin/docker \
&& rm -rf /tmp/*

# drop back to jenkins user
USER jenkins

# install plugins and disable "install plugins banner"
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false -Djava.util.logging.config.file=/var/jenkins_home/log.properties"

# start the wrapper script as user root
USER root
ENTRYPOINT ["/entrypoint.sh", "/start-jenkins.sh"]

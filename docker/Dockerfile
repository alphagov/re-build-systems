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

# Copy groovy script to set up Github authentication
COPY files/out/github_oauth_plugin_script.groovy /var/jenkins_home/
# TODO: Change the directory in the above - unsure where the groovy script needs to be copied (code is work-in-progress).

COPY files/start-jenkins.sh /start-jenkins.sh
RUN chmod +x /start-jenkins.sh

# copy list of plugins
COPY files/plugins.txt /usr/share/jenkins/ref/plugins.txt

# enable logging
COPY files/log.properties /usr/share/jenkins/ref/log.properties

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

# drop back to jenkins user
USER jenkins

# install plugins and disable "install plugins banner"
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false -Djava.util.logging.config.file=/var/jenkins_home/log.properties"

# start the wrapper script as user root
USER root
ENTRYPOINT ["/entrypoint.sh", "/start-jenkins.sh"]

FROM jenkins/jenkins:lts

# 80 = nginx
# 8080 = jenkins
# 50000 = jenkins workers
EXPOSE 50000 80

# Google authentication details for OAuth2. Pass in these details in environment variables.
# To obtain new details, visit https://developers.google.com/identity/sign-in/web/sign-in
# Example: --build-arg=googleAuthClientId=678464777343-lgdtrjro69dnhud030hed3f09cr7mkge.apps.googleusercontent.com
#          --build-arg=googleAuthClientSecret=xyFcGjEBrEBVYBRxo3n4l5RW
#          --build-arg=ecsEndpointStaticIP=http://18.130.36.230
ARG googleAuthClientId
ARG googleAuthClientSecret
ARG ecsEndpointStaticIP
# Old way, using environment variables. Have not removed this code yet since we may want to do it this way
#  # Example: export GOOGLE_AUTH_CLIENT_ID=678464777343-lgdtrjro69dnhud030hed3f09cr7mkge.apps.googleusercontent.com
#  #          export GOOGLE_AUTH_CLIENT_SECRET=xyFcGjEBrEBVYBRxo3n4l5RW
#  #          export ECS_ENDPOINT_STATIC_IP=http://18.130.36.230
#  ENV GOOGLE_AUTH_CLIENT_ID
#  ENV GOOGLE_AUTH_CLIENT_SECRET
#  ENV ECS_ENDPOINT_STATIC_IP
# For more information on how these plug in to Jenkins, see https://github.com/jenkinsci/google-login-plugin and https://jenkins.io/doc/book/system-administration/security/.

# For use within this Dockerfile, not to be passed in from outside.
ARG sedPatternReplace = "s/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g"

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

# set the number of executors
COPY files/executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

# enable logging
COPY files/log.properties /var/jenkins_home/log.properties

# disable security
#COPY config.xml  /usr/share/jenkins/ref/config.xml

# Change config.xml to enable google-login plugin (Google OAuth2 login for Jenkins).
RUN cp -p $JENKINS_HOME/config.xml $JENKINS_HOME/config.$$.xml
RUN cat $JENKINS_HOME/config.xml | \
    sed 's/<securityRealm class="hudson.security.SecurityRealm\$None"\/>/<securityRealm class="org.jenkinsci.plugins.googlelogin.GoogleOAuth2SecurityRealm">\n    <clientId>$(echo $googleAuthClientId | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')<\/clientId>\n    <clientSecret>$(echo googleAuthClientSecret | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')<\/clientSecret>\n    <domain>$(echo $ecsEndpointStaticIP | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g'domain>\n  <\/securityRealm>/g' > $JENKINS_HOME/config_new.xml && \
    mv $JENKINS_HOME/config_new.xml $JENKINS_HOME/config.xml

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

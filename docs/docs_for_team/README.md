# Documentation for the product team

## Provisioning of the Jenkins

Documentation is in [the main README of the repo].

## Customising your Jenkins

You can add jobs, add agent images, install extra plugins or customise the Jenkins configuration.

**Note: ** Please add only plugins you really need, as plugins make upgrading more difficult and may potentially introduce instabilities.

To do that, edit `files >> custom-script.groovy` in the example you are following. There are four sections that you may customise as marked with title comments.

You can also customise the configuration of the EC2 instances by editing the files in the `cloud-init` folder of the example you are following.

**Note: ** There is currently a limit of 16KB for the custom code.

After the changes you need to reprovision Jenkins, as explained in the next section.

## Re-provision Jenkins

There are a few steps needed to load the new customised configuration:

1. SSH into the master EC2 instance

1. Stop the docker container by running `docker stop [container_id]`

1. Delete the content of the EFS volume (`rm -rf /mnt/jenkins-efs/*`) - this is because Jenkins will not run your updated configuration if it detects the configuration has already been set up. You should be able to backup your job history before you do that, if you need to restore it later.

1. Run `terraform plan` and `terraform apply` as you would normally do to provision the infrastructure (if you use AssumeRole, run the few extra steps you follow during the first provisioning)

1. Terminate the running master EC2 instance (e.g. using the AWS console) - a new instance will be launched automatically with the updated launch configuration.

1. Restart Jenkins using the UI. This is so that the jobs in the `custom-script` will be registered.


## How to set up a job using Jenkinsfile

We have an [example of a project] that can be built using this Jenkins platform - it has a [Jenkinsfile] that can be used as a reference when working through this README.

That project is built by running the `build-sample-java-app` job, which is included in the examples.

There are a number of steps to set up a job using Jenkinsfile each of which will be explained below:

1. Build a Docker image for the Jenkins agent

2. Publish the Docker image

3. Link the Docker image to your Jenkins

4. Specify the Docker Image label in the Jenkinsfile

5. Create the Jenkins job

6. Restart Jenkins

### 1. Build a Docker image for the Jenkins agent

The Docker container of your Jenkins agent has two responsibilities; communicating with the Jenkins master and carrying out the work specified by the job.

Therefore, we will need to have two sets of software installed on it:

* The tools required for this master - agent communication

* The tools needed to execute the Jenkins job - e.g. JDK, Ruby, ... - which we will call the `toolchain`

As a container can inherit from only one image, we have two possibilities:

#### Build the container based on the Jenkins slave

The Jenkins software depends on Java, so the `jenkins/jnlp-slave` image already installs the JDK (Java Development Kit) for Java 8, using Debian 9 as operating system (at the time of writing).


```
FROM jenkins/jnlp-slave

INSTALL all of the things needed to run your job
...
..
.
```
#### Build the container based on the toolchain

The following example is from a Dockerfile from a simple ruby project and there are a few parts to it.

* Build your toolchain, it should install all of the prerequisites to running your job. If you have an existing docker image you could inherit from that and simply install JDK 8 and append the lines that install the Jenkins software:

```
FROM ruby

RUN apt update
RUN apt install -y ruby-dev
RUN apt install -y bundler
[reducted]
```

* On top of it, install JDK 8, as it is needed by the Jenkins software - this step isn't necessary if your base image has the JDK 8.

* Append these lines to install the Jenkins software provided the base image is based on Debian or Ubuntu:

```
ARG user=jenkins
ARG group=jenkins
ARG uid=10000
ARG gid=10000

USER root
ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m ${user}

ARG VERSION=3.20
ARG AGENT_WORKDIR=/home/${user}/agent
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}
VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

USER root
RUN curl --create-dirs -SLo /usr/local/bin/jenkins-slave https://raw.githubusercontent.com/jenkinsci/docker-jnlp-slave/master/jenkins-slave \
  && chmod 755 /usr/local/bin/jenkins-slave

USER ${user}
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
```

### 2. Publish the Docker image

After building the image, you have to publish it to a repository (e.g. Docker Hub) so that it can be referenced from Jenkins.

### 3. Link the Docker image to your Jenkins

The link between your Docker image and Jenkins instance can be defined as a new agent in `files >> custom-script.groovy` of the example you followed.

### 4. Specify the Docker Image label in the Jenkinsfile

A line like this should be added to the top of the Jenkinsfile in the project you want to add and must match the labelString from the previous step:

```
agent {
    label 'sample-docker-jnlp-java-agent'
}
```

### 5. Create the Jenkins job

The last step is to create a new job that will use the Jenkinsfile of the repository.

If you are writing a new groovy script then it may be useful to test it first using the Jenkins UI. This can be found under `Jenkins >> Manage Jenkins >> Script Console`.

Both the `complete_deployment_of_dns_and_jenkins` and the `gds_specific_dns_and_jenkins` examples have a custom script loaded at initialisation under `files >> custom-script.groovy`. In that file you need to add an entry to the list of existing jobs.

### 6. Restart Jenkins

Restart Jenkins using the UI. This is so that jobs are loaded up from the `custom-script.groovy` file.

## Known bugs

As it stands Docker configuration is loaded from a git branch specified in the [cloud init yaml file]. If you make changes to your Docker config, including adding an image as in the instructions above, you must make sure that your changes are pushed to a branch on git. Before running a `terraform apply` you will need to update the [Jenkins variables file] with the name of your working branch rather than master. In this way the name of your working branch need never be committed to git. We are planning on automating this process.

## Decommissioning of the Jenkins

There are 4 steps to decommission the Jenkins platform for one of your environments:

* decommissioning the Jenkins infrastructure, via `terraform destroy`

* decommissioning the DNS infrastructure, via `terraform destroy`

* deleting the S3 buckets used for the Terraform state files

* deleting the Github OAuth app

### Before you start

1. Move to the directory in which you cloned the repository originally.\
If you don't have it anymore, clone the repository again and customise the `terraform.tfvars`
as you did during the provisioning steps, for both the `terraform\dns` and `terraform\jenkins` directories.

1. Make sure you still have this in `~/.aws/credentials`, otherwise add it again:

       ```
       [re-build-systems]
       aws_access_key_id = [your aws key here]
       aws_secret_access_key = [your aws secret here]
       ```

1. Export those credentials

   If you are using bash, then add a space at the start of export AWS_ACCESS_KEY_ID and export AWS_SECRET_ACCESS_KEY to prevent them from being added to ~/.bash_history.

   ```
   export AWS_ACCESS_KEY_ID="[aws key]"
   export AWS_SECRET_ACCESS_KEY="[aws secret]"
   export AWS_DEFAULT_REGION="eu-west-1"
   ```

1. Export these environment variables

    ```
    export JENKINS_ENV_NAME=[environment-name]
    export JENKINS_TEAM_NAME=[team-name]
    ```

### Decommissioning the Jenkins infrastructure

1. Run this from the `terraform/jenkins` directory:

    ```
    terraform destroy \
        -var environment=$JENKINS_ENV_NAME \
        -var-file=./terraform.tfvars \
        -var ssh_public_key_file=~/.ssh/build_systems_${JENKINS_TEAM_NAME}_${JENKINS_ENV_NAME}_rsa.pub
    ```

    The previous `terraform destroy` command may fail to delete everything on the first run. If so, just run it again.

    There is also a chance that this will fail and ask you to run a `terraform init`. If this happens then run the following command before trying to destroy again.

    ```
    terraform init \
        -backend-config="region=$AWS_DEFAULT_REGION" \
        -backend-config="key=re-build-systems.tfstate" \
        -backend-config="bucket=tfstate-$JENKINS_TEAM_NAME-$JENKINS_ENV_NAME"
    ```

### Decommissioning the DNS infrastructure

1. Run this from the `terraform/dns` directory:

    ```
    terraform destroy -var-file=./terraform.tfvars
    ```

    The previous `terraform destroy` command may fail to delete everything on the first run. If so, just run it again.

    There is also a chance that this will fail and ask you to run a `terraform init`. If this happens then run the following command before trying to destroy again.

    ```
    terraform init \
        -backend-config="region=$AWS_DEFAULT_REGION" \
        -backend-config="bucket=tfstate-dns-$JENKINS_TEAM_NAME.build.gds-reliability.engineering" \
        -backend-config="key=$JENKINS_TEAM_NAME.build.gds-reliability.engineering.tfstate"
    ```

### Deleting the Terraform state S3 buckets

1. Make sure you have `jq` (version `> 1.5.0`) installed

1. Run these commands from the `tools` directory:

    ```
    ./delete-s3-bucket tfstate-dns-$JENKINS_TEAM_NAME.build.gds-reliability.engineering
    ```

    ```
    ./delete-s3-bucket tfstate-$JENKINS_TEAM_NAME-$JENKINS_ENV_NAME
    ```

### Deleting the Github OAuth app

Go to [Github developer settings] > `OAuth Apps` > Select the app > `Delete application`


[the main README of the repo]: https://github.com/alphagov/re-build-systems
[example of a project]: https://github.com/alphagov/re-build-systems-sample-java-app/tree/jenkinsfile-supported-by-re-build-mvp
[Jenkinsfile]: https://jenkins.io/doc/book/pipeline/jenkinsfile/
[cloud init yaml file]: /terraform/jenkins/cloud-init/server-asg-xenial-16.04-amd64-server.yaml
[Jenkins variables file]: /terraform/jenkins/variables.tf
[help page]: https://wiki.jenkins.io/display/JENKINS/Docker+Plugin
[Github developer settings]: https://github.com/settings/developers
[example groovy script]: https://github.com/alphagov/terraform-aws-re-build-jenkins/blob/import_jobs/docker/files/groovy/jobs/build-sample-java-app.groovy

# Jenkins build system shared responsibility

Reliability Engineering uses a [shared responsibility model](https://aws.amazon.com/compliance/shared-responsibility-model/) to provide the Jenkins build system to GDS product teams as [Infrastructure as code (IaC)](https://en.wikipedia.org/wiki/Infrastructure_as_Code). The Reliability Engineering team keeps the core build stable and updated, and GDS teams manage the host infrastructure including security and user management.

Reliability Engineering is only responsible for internal GDS product teams who adopt the [Jenkins build system](https://github.com/alphagov/re-build-systems).

## Reliability Engineering responsibilities

All Jenkins build releases are fully tested for stability by the Reliability Engineering team before release. If you experience problems with the build system, contact us using the [#reliability-engineering Slack channel](https://gds.slack.com/messages/CAD6NP598/#). You can also [raise an issue using GitHub](https://github.com/alphagov/re-build-systems/issues).

### Provision Amazon Web Services (AWS) accounts and URLs

Reliability Engineering provisions AWS accounts, which allow you to build the Jenkins build system host infrastructure.

Beneath the `build.gds-reliability.engineering` domain, Reliability Engineering maintains a TLS URL for Jenkins installations to provide secure network communication.

### Provide stable builds

Reliability Engineering provides stable builds by upgrading [supported core Jenkins, plugins and their dependencies](https://github.com/alphagov/terraform-aws-re-build-jenkins).

### Act on vulnerabilities

Reliability Engineering fix critical vulnerabilities by testing and releasing updated, stable builds. This includes vulnerabilities relating to [Jenkins](https://ci.jenkins.io/), supported plugins and their dependencies.

## Product team responsibilities

### Update and upgrade

You should upgrade your Jenkins system when Reliability Engineering releases new stable builds. Read our [upgrade guidance to do this](https://github.com/alphagov/re-build-systems/blob/master/docs/docs_for_team/README.md)

### Agent images

To run jobs you must [create your own](docs_for_team/README.md#1-build-a-docker-image-for-the-jenkins-agent) [Docker](https://www.docker.com/) [Docker](https://www.docker.com/) images.

Reliability Engineering provides a Jenkins Agent Docker image for basic Java applications. The team does not actively support additional programming languages and frameworks. You can use them if you are able to support yourself. 

You should build your agent Docker images using well-supported, existing images, such as the [Ubuntu image](https://hub.docker.com/_/ubuntu/) or the [official NGINX image](https://hub.docker.com/_/nginx/).

### Third-party and unsupported plugins

You must [track all vulnerabilities](https://jenkins.io/security/) and upgrades and test new versions of any third party plugins.

### Secure the host infrastructure

You must secure your AWS infrastructure. For example:

* control egress traffic by [implementing VPC egress controls](https://aws.amazon.com/answers/networking/controlling-vpc-egress-traffic/)
* use [TLS and other secure protocols](https://www.ncsc.gov.uk/guidance/tls-external-facing-services) to protect data
* use secure coding practices like peer review
* secure developer machines - ask the GDS IT team for guidance
* manage secrets to [secure the build and deployment pipeline](https://www.ncsc.gov.uk/guidance/secure-build-and-deployment-pipeline)
* control access to provisioned machines and other AWS services
* implement protective monitoring and [logging for security purposes](https://www.ncsc.gov.uk/guidance/introduction-logging-security-purposes)
* use [security hardening for VMs](https://gds-way.cloudapps.digital/standards/operating-systems.html)
* enabling infrastructure monitoring using [AWS CloudWatch](https://aws.amazon.com/cloudwatch/)

You must [transfer ownership](https://github.com/alphagov/re-build-systems/blob/master/examples/gds_specific_dns_and_jenkins/README.md#provision-the-main-jenkins-infrastructure) of the OAuth app to the [GitHub alphagov organisation](https://github.com/alphagov) once you have provisioned Jenkins. This prevents unauthorised access to the build system if the owner of the OAuth app leaves GDS.

### Additional services and infrastructure

You must supply other tooling and services for your Jenkins build, like [log management](https://reliability-engineering.cloudapps.digital/#logging). The build system enables log production but it does not export or process them.

### User management

You should manage who can access the build system and make sure you remove access when people leave your team or GDS.

Because build system authentication and authorisation are implemented using GitHub OAuth you must manage your team’s membership to the GitHub organisation that owns the OAuth app. For GDS this is [GitHub alphagov organisation](https://github.com/alphagov).

We recommend your team keeps a list of users held in the AWS account hosting the Jenkins infrastructure. This way you can track who has access to the build system.

## Third party responsibilities

Third party providers are responsible for making sure their systems are updated and available.

### Amazon

Amazon maintains the AWS infrastructure and is responsible for updating it. Reliability Engineering and product teams do not need to update or upgrade AWS.

### Docker.io

When you provision or reprovision your infrastructure you use the latest version of Docker. Docker is responsible for the maintenance and support of new and current versions.

### Ubuntu

Reliability Engineering uses Ubuntu as the operating system for [Amazon Elastic Compute Cloud (Amazon EC2)](https://aws.amazon.com/ec2/) instances. instances. Because an `apt-get update` is run each time a `terraform apply` is performed, for example after we release a change to our infrastructure, you will be using the current version of Ubuntu [(the Long-Term Support (LTS) version is 16.04)](https://wiki.ubuntu.com/Releases).

Ubuntu is responsible for maintaining the versions of its components.

### Jenkins Project

The master Amazon EC2 node uses the most recent [Long-Term Support (LTS) version of the Docker image](https://hub.docker.com/r/jenkins/jenkins/) provided by the Jenkins project. When you reprovision Jenkins, for example, when upgrading to the latest stable release, you will automatically apply the latest available Docker image.

For example, when you start a new [NGINX](https://www.nginx.com/) Docker image, [Terraform](https://www.terraform.io/) code updates it with the latest available components including security patches.

### Plugin providers

Plugin providers are responsible for updates and fixing vulnerabilities or bugs.

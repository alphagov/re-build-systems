# Jenkins build system shared responsibility

Reliability Engineering use a [shared responsibility model](https://aws.amazon.com/compliance/shared-responsibility-model/) to provide the Jenkins build system to GDS product teams as [Infrastructure as code (IaC)](https://en.wikipedia.org/wiki/Infrastructure_as_Code). Reliability Engineering keep the core build stable and updated, GDS teams manage the host infrastructure including security and user management.

Reliability Engineering is only responsible for internal GDS product teams who adopt the Jenkins build system.

## Reliability Engineering responsibilities

All releases are fully tested before release. If you experience problems with the build system contact us using the [#reliability-engineering Slack channel](https://gds.slack.com/messages/CAD6NP598/#). You can also [raise an issue](https://github.com/alphagov/re-build-systems/issues) using GitHub.

### Provision Amazon Web Services (AWS) accounts and URLs

Reliability Engineering provisions AWS accounts allowing you to build the Jenkins build system host infrastructure.

Beneath the `build.gds-reliability.engineering` domain, Reliability Engineering maintain a TLS URL for Jenkins installations to provide secure network communication.

### Provide stable builds

Reliability Engineering provides stable builds of the module by regularly upgrading and testing the supported core Jenkins version and a base set of plugins (with their dependencies).  It is your responsibility to regularly update the module and conduct further testing within your specific environment.

* [Jenkins Version](https://github.com/alphagov/terraform-aws-re-build-jenkins/blob/master/versions.tf)
* [Terraform Module Releases](https://github.com/alphagov/terraform-aws-re-build-jenkins/releases)
* [Plugin Versions](https://github.com/alphagov/terraform-aws-re-build-jenkins/blob/master/docker/files/plugins.txt)

### Act on vulnerabilities

Reliability Engineering fix critical vulnerabilities by testing and releasing updated, stable builds. This includes vulnerabilities relating to [Jenkins](https://ci.jenkins.io/), supported plugins and their dependencies.

## Product team responsibilities

### Update and upgrade

You should upgrade your Jenkins system when new stable builds are released by Reliability Engineering.

### Agent images

To run jobs you must [create their own](docs_for_team/README.md#1-build-a-docker-image-for-the-jenkins-agent) [Docker](https://www.docker.com/) images.

Reliability Engineering provide an agent Docker image to use for basic Java applications. Additional programming languages and frameworks are not actively supported by RE, but can of course be used.

You should build your agent Docker images using well-supported, existing images, such as the [ubuntu image](https://hub.docker.com/_/ubuntu/) or the [official nginx image](https://hub.docker.com/_/nginx/).

### Third party and unsupported plugins

You must track all vulnerabilities, upgrades and test new versions of any third party plugins.

### Secure the host infrastructure

You must secure your AWS infrastructure. For example:

* control egress traffic by [implementing VPC egress controls](https://aws.amazon.com/answers/networking/controlling-vpc-egress-traffic/)
* use [TLS and other secure protocols](https://www.ncsc.gov.uk/guidance/tls-external-facing-services) to protect data
* use secure coding practices like peer review
* secure developer machines, ask your IT team for guidance
* manage secrets to [secure the build and deployment pipeline](https://www.ncsc.gov.uk/guidance/secure-build-and-deployment-pipeline)
* control access to provisioned machines and other AWS services
* implement protective monitoring and [logging](https://www.ncsc.gov.uk/guidance/introduction-logging-security-purposes), for security purposes
* using [security hardening for VMs](https://gds-way.cloudapps.digital/standards/operating-systems.html)
* enable infrastructure monitoring using [AWS CloudWatch](https://aws.amazon.com/cloudwatch/)

You must [transfer ownership](https://github.com/alphagov/re-build-systems/blob/master/examples/gds_specific_dns_and_jenkins/README.md#provision-the-main-jenkins-infrastructure) of the GitHub OAuth app to `alphagov` once you have provisioned Jenkins. This prevents unauthorised access to the build system if the owner of the OAuth app leaves the organisation.

### Additional services and infrastructure

You must supply other tooling and services. For example, for log management, the build system enables log production but it does not export or process them.

### User management

You should manage who can access the build system and make sure you remove people’s access when they leave your team or GDS.

Because build system authentication and authorisation are implemented using GitHub OAuth you must manage your team’s membership to the GitHub organisation owning the OAuth app (this would be `alphagov` if you are at GDS).

It’s recommended your team keeps a list of users held in the AWS account hosting the Jenkins infrastructure to track who has access to the build system.

## Third party responsibilities

Third party providers are responsible for making sure their systems are updated and available.

### Amazon

Amazon maintains the AWS infrastructure and is responsible for updating it. Reliability Engineering and product teams do not need to update or upgrade AWS.

### Docker.io

When you provision or reprovision your infrastructure you use the latest version of Docker. Docker is responsible for the maintenance and support of new and current versions.

### Ubuntu

Reliability Engineering use Ubuntu as the operating system for [Amazon Elastic Compute Cloud (Amazon EC2)](https://aws.amazon.com/ec2/) instances. Because an `apt-get update` is run each time a `terraform apply` is performed (for instance after we release a change to our infrastructure) you will be using the current version of Ubuntu (within the chosen long-term support (LTS) version, which is 16.04).

Ubuntu is responsible for maintaining the versions of its components.

### Jenkins Project

The master Amazon EC2 node uses the most recent [Long-Term Support (LTS) version](https://hub.docker.com/r/jenkins/jenkins/) of the Docker image provided by the Jenkins Project. When you reprovision Jenkins (for example, when upgrading to the latest stable release) you automatically apply the latest available image.

When new images start, [Terraform](https://www.terraform.io/) code updates them with the latest components, like [Nginx](https://www.nginx.com/), making sure current security updates are included.

### Plugin providers

Plugin providers are responsible for updates and fixing vulnerabilities or bugs.

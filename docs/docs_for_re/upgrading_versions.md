# Releasing updated versions of the RE Jenkins

## Purpose of this document

This document is for the maintainers of the [re-build-systems](https://github.com/alphagov/re-build-systems), [terraform-aws-re-build-dns](https://github.com/alphagov/terraform-aws-re-build-dns) and [terraform-aws-re-build-jenkins](https://github.com/alphagov/terraform-aws-re-build-jenkins) github repositories.

It covers how to upgrade versions of Terraform, Jenkins, Jenkins plugins and other software on which the [re-build-systems Jenkins instance](https://github.com/alphagov/re-build-systems) is based.

This document does not cover upgrading of Linux Ubuntu versions, not does it cover upgrading the version of Docker.

## Important note

We should only be using LTS (long term support) versions of software.

## Upgrading Terraform version

This is the version of Terraform you use to provision your Jenkins.

You can find the current version of Terraform in the `main.tf` files in each of the [terraform-aws-re-build-dns](https://github.com/alphagov/terraform-aws-re-build-dns) and [terraform-aws-re-build-jenkins](https://github.com/alphagov/terraform-aws-re-build-jenkins) modules.

If you need to upgrade the version, change the `required_version` entry in these `main.tf` files and test the change as described below.

Please note also that you need to upgrade the version of Terraform on your laptop to be at least the same version as that in the [dns provider](https://github.com/alphagov/re-build-systems/blob/master/examples/gds_specific_dns_and_jenkins/dns/provider.tf) and [jenkins provider](https://github.com/alphagov/re-build-systems/blob/master/examples/gds_specific_dns_and_jenkins/jenkins/provider.tf) files.

## Upgrading providers

You may need to upgrade some of the providers' version in the `provider.tf` files of the examples.

## Upgrading Jenkins version

To change the version of Jenkins, just change the `jenkins_version` in the https://github.com/alphagov/terraform-aws-re-build-jenkins/blob/master/versions.tf file.

## Updating the EFS Utils

[This](https://github.com/aws/efs-utils) is the repository of the project. Unfortunately the maintainers don't publish releases.

You will need to compile the software on one of the Jenkins EC2 instances and then move the `.deb` package to [here](https://github.com/alphagov/terraform-aws-re-build-jenkins/tree/master/packages).

As the process is quite involving, it is probably a good idea to go through it only if there any important updates (e.g. relevant security patches).

## Testing upgraded version

If you have changed anything then just commit your changes to a git branch.

Once your changes have been committed, run through the examples in https://github.com/alphagov/re-build-systems/tree/master/examples and verify you can log into the Jenkins instance without any errors.

Make sure the module source specified in the `main.tf` file of the example you are following points to the branch you are testing, e.g.:
```
source = "git::https://github.com/alphagov/terraform-aws-re-build-jenkins.git?ref=version_upgrade"
```

## Upgrading Jenkins plugins

1. In the test Jenkins, go to the `Plugin manager` and update all the plugins to the latest version. Make sure you have uninstalled the `greenballs` plugin before you do that, as that plugin was installed only as an example and it is not part of the small set of our supported plugins.

1. Use [this script](https://github.com/alphagov/re-build-systems/blob/master/tools/generate-plugin-list) to download the list of plugins.

1. Update [this file](https://github.com/alphagov/terraform-aws-re-build-jenkins/blob/master/docker/files/plugins.txt).


## Create new modules releases

Once both branches has been merged to master create new Github releases of both modules:  [jenkins](https://github.com/alphagov/terraform-aws-re-build-jenkins/releases) and [dns](https://github.com/alphagov/terraform-aws-re-build-dns/releases).

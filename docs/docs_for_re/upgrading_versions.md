# Upgrading third-party dependencies

## Purpose of this document

This document is for the maintainers of the [re-build-systems](https://github.com/alphagov/re-build-systems), [terraform-aws-re-build-dns](https://github.com/alphagov/terraform-aws-re-build-dns) and [terraform-aws-re-build-jenkins](https://github.com/alphagov/terraform-aws-re-build-jenkins) github repositories.

It covers how to upgrade versions of Terraform, Jenkins and Jenkins plugins on which the [re-build-systems Jenkins instance](https://github.com/alphagov/re-build-systems) is based.

This document does not cover upgrading of Linux Ubuntu versions, not does it cover upgrading the version of Docker.

## Important note

We should only be using lts (long term support) versions of software.

## Upgrading Terraform version

This is the version of Terraform you use to provision your Jenkins.

You can find the current version of Terraform in the `main.tf` files in each of the [terraform-aws-re-build-dns](https://github.com/alphagov/terraform-aws-re-build-dns) and [terraform-aws-re-build-jenkins](https://github.com/alphagov/terraform-aws-re-build-jenkins) modules.

If you need to upgrade the version, change the `required_version` entry in these `main.tf` files and test the change as described below.

Please note also that you need to upgrade the version of Terraform on your laptop to be at least the same version as that in the [dns provider](https://github.com/alphagov/re-build-systems/blob/master/examples/gds_specific_dns_and_jenkins/dns/provider.tf) and [jenkins provider](https://github.com/alphagov/re-build-systems/blob/master/examples/gds_specific_dns_and_jenkins/jenkins/provider.tf) files.

## Upgrading Jenkins version

Currently, the Jenkins version is specified in the [terraform-aws-re-build-jenkins](https://github.com/alphagov/terraform-aws-re-build-jenkins) module.

To change the version of Jenkins, just change the `jenkins_version` in the https://github.com/alphagov/terraform-aws-re-build-jenkins/blob/master/versions.tf file.

## Testing upgraded version

If you have changed the versions of Terraform, Jenkins or Jenkins plugins then just commit your changes to a git branch. Once your changes have been committed, run through the examples in https://github.com/alphagov/re-build-systems/tree/master/examples and verify you can log into the Jenkins instance without any errors.

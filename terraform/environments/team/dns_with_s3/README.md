# Example configuration

## Overview

This is an example of a configuration where the state (i.e. details of the AWS cloud infrastructure) for both DNS and Jenkins is contained within one S3 bucket.

## How to use

1. Set AWS environment variables

  ```
  export AWS_ACCESS_KEY_ID="[aws key]"
  export AWS_SECRET_ACCESS_KEY="[aws secret]"
  export AWS_DEFAULT_REGION="eu-west-1"
  ```

2. Create a `terraform.tfvars` file with the following variables:

  ```
  environment=[your environment, e.g. test]
  team_name=[name of your team or team who owns the Jenkins instance]
  main_domain_name=[root of the domain name which is used to reference the Jenkins instance]
  aws_region=[needs to be same value as the $AWS_DEFAULT_REGION environment variable in step 1 above]
  ```

  This `terraform.tfvars` file needs to be created in this directory.

3. In this directory, run:

  ```
  terraform init
  ```

4. Create the S3 bucket and plan for the dns infrastructure.

  ```
  terraform plan -var-file=terraform.tfvars -out plan.$$
  terraform apply plan.$$
  ```

5. Create the DNS infrastructure

  ```
  cd dns
  terraform apply latest_plan.out
  ```

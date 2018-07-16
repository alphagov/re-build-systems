# Example configuration

## Overview

This is an example of a configuration where the state (i.e. details of the AWS cloud infrastructure) for both DNS and Jenkins is contained within one S3 bucket.

_This is not necessarily desirable. For most cases, it is a good idea to separate these states out so they are kept in separate S3 buckets._

## How to use

Pass in the `allowed_ips` and `ssh_public_key_file` variables in a variables file, along the lines of:

```
export JENKINS_ENV_NAME=modules-test-env
export JENKINS_TEAM_NAME=modules-test-team
```

```
export AWS_ACCESS_KEY_ID="[aws key]"
export AWS_SECRET_ACCESS_KEY="[aws secret]"
export AWS_DEFAULT_REGION="eu-west-1"
```

```
../../../tools/create-s3-state-bucket
    -t $JENKINS_TEAM_NAME \
    -e $JENKINS_ENV_NAME \
    -p re-build-systems
```

```
terraform apply \
    -var-file=./terraform.tfvars  \
    -var environment=$JENKINS_ENV_NAME \
    -var ssh_public_key_file=[path to public key]]
```

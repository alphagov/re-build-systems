# Example configuration

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
    -var ssh_public_key_file=[path to public key]
```

# Example uri is https://jenkins2.modules-test-env.modules-test-team.build.gds-reliability.engineering

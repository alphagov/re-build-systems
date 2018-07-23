# Example configuration

## Overview

This is an example of a configuration where the state (i.e. details of the AWS cloud infrastructure) for both DNS and Jenkins is contained within one S3 bucket.

_This is not necessarily desirable. For most cases, it is a good idea to separate these states out so they are kept in separate S3 buckets._

## How to use

Pass in the `allowed_ips` and `ssh_public_key_file` variables in a variables file, along the lines of:

```
export TEAM_NAME=modules-test-dns

../../../tools/create-dns-s3-state-bucket \
  -d build.gds-reliability.engineering \
  -p re-build-systems \
  -t $TEAM_NAME
```

```
export AWS_ACCESS_KEY_ID="[aws key]"
export AWS_SECRET_ACCESS_KEY="[aws secret]"
export AWS_DEFAULT_REGION="eu-west-1"
```

```
terraform init \
    -backend-config="region=$AWS_DEFAULT_REGION" \
    -backend-config="bucket=tfstate-dns-$TEAM_NAME.build.gds-reliability.engineering" \
    -backend-config="key=$TEAM_NAME.build.gds-reliability.engineering.tfstate"
```

```
terraform plan -out plan.$$
terraform apply plan.$$
```

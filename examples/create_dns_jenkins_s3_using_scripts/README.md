# Instructions for use

Please refer to the README.md file in the root directory of this repository. The steps used to run this example are listed below but are almost the same as those in the main README.md file in the root directory of this repository.

## How to use this example

### Before you start

Firstly, ensure that you have symlinks created from each of the `jenkins` and `dns` directories. It assumes these modules are downloaded locally and the user needs to add links from the examples/default_example/jenkins and examples/default_example/dns directories to the module locations, something along the lines of:

In the root directory of this repository, run:

```
ln -s [path to dns module] examples/default_example/dns/dns_module
ln -s [path to Jenkins module] examples/default_example/jenkins/jenkins_module
```

The dns module is located in the https://github.com/alphagov/terraform-aws-re-build-dns repository and the jenkins module is located in the https://github.com/alphagov/terraform-aws-re-build-jenkins repository so you can check out these repositories locally.

### Steps

`cd examples/default_example`

```
export AWS_ACCESS_KEY_ID=[you AWS access key]
export AWS_SECRET_ACCESS_KEY=[your AWS secret access key]
export AWS_DEFAULT_REGION=eu-west-1

export JENKINS_TEAM_NAME=team1

../../tools/create-dns-s3-state-bucket \
    -d build.gds-reliability.engineering \
    -p re-build-systems \
    -t $JENKINS_TEAM_NAME

cd dns

terraform init \
    -backend-config="region=$AWS_DEFAULT_REGION" \
    -backend-config="bucket=tfstate-dns-$JENKINS_TEAM_NAME.build.gds-reliability.engineering" \
    -backend-config="key=$JENKINS_TEAM_NAME.build.gds-reliability.engineering.tfstate"

terraform apply
```

>Outputs:

>team_zone_id = AAAAAAAAAAAAAA
team_zone_nameservers = [
    ns-1111.awsdns-10.org,
    ns-222.awsdns-10.co.uk,
    ns-33.awsdns-10.com,
    ns-444.awsdns-10.net
]

```
export JENKINS_ENV_NAME=test
export JENKINS_TEAM_NAME=team1

../../../tools/create-s3-state-bucket \
    -t $JENKINS_TEAM_NAME \
    -e $JENKINS_ENV_NAME \
    -p re-build-systems

cd ../jenkins

terraform init \
    -backend-config="region=$AWS_DEFAULT_REGION" \
    -backend-config="key=re-build-systems.tfstate" \
    -backend-config="bucket=tfstate-$JENKINS_TEAM_NAME-$JENKINS_ENV_NAME"

terraform apply \
    -var-file=./terraform.tfvars  \
    -var environment=$JENKINS_ENV_NAME \
    -var github_client_id=$JENKINS_GITHUB_OAUTH_ID \
    -var github_client_secret=$JENKINS_GITHUB_OAUTH_SECRET \
    -var ssh_public_key_file=[path to your ssh public key]
```

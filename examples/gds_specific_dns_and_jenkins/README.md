# Example configuration for GDS teams

This working example specific to GDS users demonstrates how you can use our modules to deploy Jenkins using Terraform.  By working through the example it will result in you having a working deployment of Jenkins using our Terraform modules.

To work through this example you will need to clone this repo.

There are 3 initial steps to set up your Jenkins platform:

1. Provision the DNS infrastructure.

1. Configure and provision the main Jenkins infrastructure.

1. Sign into your new Jenkins and try it out.

You'll only need to provision the DNS infrastructure once and ask Reliability Engineering to enable your new domain, this may take up to 2 working days. Once this step is complete you can provision the main Jenkins infrastructure anytime you need to create a new environment.

Each environment you create will have a URL like this:

`https://[environment_name].[team_name].build.gds-reliability.engineering`

Read the [architectural documentation] for more information about the build system architecture.

## Prerequisites

Before you start you'll need:

* a basic understanding of how to use [Terraform]

* an AWS user account with administrator access

* [Terraform v0.11.7] installed on your laptop. This needs to be the same version as that in the [dns provider](https://github.com/alphagov/re-build-systems/blob/master/examples/gds_specific_dns_and_jenkins/dns/provider.tf) and [jenkins provider](https://github.com/alphagov/re-build-systems/blob/master/examples/gds_specific_dns_and_jenkins/jenkins/provider.tf) files

* [AWS Command Line Interface (CLI)] installed on your laptop

## Provision the DNS infrastructure

Provisioning the DNS infrastructure allows you to set up the URLs you will use to access your Jenkins.

You'll need to provision a separate Jenkins for each environment you want to create. For example, you might want separate development and production environments, these environments will have different URLs.

Start by provisioning the DNS for one environment, add other environments later. You'll also need to choose your team name, which will be part of the Jenkins URL.

### Configure the DNS infrastructure

1. Add your AWS user credentials to `~/.aws/credentials`. If this file does not exist, you'll need to create it.

	```
	[re-build-systems]
	aws_access_key_id = [your aws key here]
	aws_secret_access_key = [your aws secret here]
	```

1. Set AWS environment variables

	**Note:** Our modules use AWS EFS for persistent storage and currently EFS is not available in the London region (eu-west-2), in this example we will use Ireland (eu-west-1).

	**Note:** If you're using bash, add a space at the start of `export AWS_ACCESS_KEY_ID` and `export AWS_SECRET_ACCESS_KEY` to prevent them from being added to `~/.bash_history`.

	```
	export AWS_ACCESS_KEY_ID="[aws key]"
	export AWS_SECRET_ACCESS_KEY="[aws secret]"
	export AWS_DEFAULT_REGION="eu-west-1"
	```

1. Set Jenkins related environment variables

	```
	export JENKINS_TEAM_NAME="[my-team-name]"
	```

1. Clone the re-build-systems repo

	```
	git clone https://github.com/alphagov/re-build-systems.git
	```

1. Create the [S3 bucket] to host the Terraform state file by running this command from the `tools` directory:

	```
	./create-dns-s3-state-bucket \
	  -d build.gds-reliability.engineering \
	  -p [my-aws-profile] \
	  -t $JENKINS_TEAM_NAME
	```

1. Change into the `examples/gds_specific_dns_and_jenkins/dns` directory

1. Rename the `terraform.tfvars.example` file to `terraform.tfvars`.

1. Edit the `terraform.tfvars` file to reflect the following configuration:

	| Name | Var Type | Required | Default | Description |
	| :--- | :--- | :--: | :--- | :--- |
	| `aws_profile` | string | | The default AWS profile in `~/.aws/credentials` | AWS Profile (credentials) to use |
	| `aws_region` | string | | default AWS region | The AWS Region to be used, eg. `eu-west-1` |
	| `hostname_suffix` | string | **yes** | none | Main domain name for new Jenkins instances, for GDS use `build.gds-reliability.engineering` |
	| `team_name` | string | **yes** | none | Name of your team. This is used to construct the DNS name for your Jenkins instances |

1. Initialise Terraform

	```
	terraform init \
	  -backend-config="region=$AWS_DEFAULT_REGION" \
	  -backend-config="bucket=tfstate-dns-$JENKINS_TEAM_NAME.build.gds-reliability.engineering" \
	  -backend-config="key=$JENKINS_TEAM_NAME.build.gds-reliability.engineering.tfstate"
	```

1. Run this command to apply the Terraform using your custom configuration

	```
	terraform apply -var-file=./terraform.tfvars
	```

1. You will get an output in your terminal that looks like this:

	```
	Outputs:
	team_domain_name = [team_name].build.gds-reliability.engineering
	team_zone_id = A1AAAA11AAA11A
	team_zone_nameservers = [
	  ns-1234.awsdns-56.org,
	  ns-7890.awsdns-12.co.uk,
	  ns-345.awsdns-67.com,
	  ns-890.awsdns-12.net
	]
	```

	If you receive an error, it may be because your `team_name` is not unique. Your `team_name` must be unique to ensure the associated URLs are unique. Go back to step 7, change your `team_name` and then continue from that point.

	Copy and send this output to the GDS Reliability Engineering team at reliability-engineering@digital.cabinet-office.gov.uk. The team will make your URL live.

	This step may take up to two working days, if you progress to the next step before awaiting confirmation from the GDS Reliability Engineering team, your domain will not be configured and it will cause errors when generating the TLS certificate used for HTTPS.

## Provision the main Jenkins infrastructure

Once Reliability Engineering has made your URL live, you can provision the main Jenkins infrastructure.

You'll need to choose which environment you want to set up Jenkins for, for example `ci`, `dev` or `staging` which will form part of the Jenkins URL.

1. Create a GitHub OAuth app to allow you to setup authentication to the Jenkins through GitHub.

	Go to the [Register a new OAuth application] and use the following settings to setup your app.

	The [URL] will follow the pattern `https://[environment].[team_name].[hostname_suffix]`.  For example `https://dev.my-team.build.gds-reliability.engineering`

	```
	Application name: jenkins-[environment]-[team-name] e.g. jenkins-dev-my-team
	Homepage URL: [URL]
	Application description: Build system for [URL]
	Authorization callback URL: [URL]/securityRealm/finishLogin
	```

	Then, click the 'Register application' button.

	Export the credentials as they appear on the screen:

	**Note:** If you're using bash, add a space at the start of `export JENKINS_GITHUB_OAUTH_ID` and `export JENKINS_GITHUB_OAUTH_SECRET` to prevent them from being added to `~/.bash_history`.

	```
	export JENKINS_GITHUB_OAUTH_ID="[client-id]"
	export JENKINS_GITHUB_OAUTH_SECRET="[client-secret]"
	```

	The github credentials are exported so that no secrets are stored on the local machine.

1. Transfer ownership of the Github OAuth app
	Skip this step if you are provisioning the platform only for test or development purpose. Otherwise, you should transfer ownership of the app to `alphagov` so that it can be managed by GDS.

	To do so, click the "Transfer ownership" button located at the top of the page where you copied the credentials from. Input `alphagov` as organisation.

1. Export the environment and team names set during DNS provisioning

	```
	export JENKINS_TEAM_NAME="[my-team-name]"
	export JENKINS_ENV_NAME="[my-environment]"
	```

1. Set AWS environment variables

	**Note:** If you're using bash, add a space at the start of `export AWS_ACCESS_KEY_ID` and `export AWS_SECRET_ACCESS_KEY` to prevent them from being added to ~/.bash_history.

	```
	export AWS_ACCESS_KEY_ID="[aws key]"
	export AWS_SECRET_ACCESS_KEY="[aws secret]"
	export AWS_DEFAULT_REGION="eu-west-1"
	```

1. Create the [S3 bucket] to host the Terraform state file by running this command from the `tools` directory:

	```
	./create-s3-state-bucket \
	  -t $JENKINS_TEAM_NAME \
	  -e $JENKINS_ENV_NAME \
	  -p [my-aws-profile]
	```

1. Change into the `examples/gds_specific_dns_and_jenkins/jenkins` directory

1. Rename the `terraform.tfvars.example` file to `terraform.tfvars`.

1. Edit the `terraform.tfvars` file to reflect the following configuration:

	| Name | Var Type | Required | Default | Description |
	| :--- | :--- | :--: | :--- | :--- |
	| `allowed_ips` | list | **yes** | none | A list of IP addresses permitted to access (via SSH & HTTPS) the EC2 instances created that are running Jenkins.  A list of GDS IPs are included in the terraform.tfvars.example file |
	| `append_server_user_data` | string | | blank | Location and name of `user_data` file which will be appended to the default `user_data` file before being run on the Jenkins2 master. If not specified then it will be ignored |
	| `append_worker_user_data` | string | | blank | Location and name of `user_data` file which will be appended to the default `user_data` file before being run on the Jenkins2 worker. If not specified then it will be ignored |
	| `aws_az` | string | | the first AZ in a region | Single availability zone to place master and worker instances in, eg. eu-west-1a |
	| `aws_profile` | string | | default aws profile in ~/.aws/credentials | AWS Profile (credentials) to use |
	| `aws_region` | string | | default aws region | AWS Region to use, eg. eu-west-1 |
	| `custom_groovy_script` | string | | none | Path to custom groovy script to run at end of Jenkins launch |
	| `environment` | string | **yes** | none | Environment name (e.g. production, test, ci). This is used to construct the DNS name for your Jenkins instances |
	| `jenkins_admin_users_github_usernames` | list | **yes** | none | List of Jenkins admin users' Github usernames |
	| `github_client_id` | string | **yes** | none | Your Github Auth client ID |
	| `github_client_secret` | string | **yes** | none | Your Github Auth client secret |
	| `github_organisations` | list | **yes** | none | List of Github organisations and teams that users must be a member of to allow HTTPS login to master.  For GDS it is recommended that alphagov AND a team be specified, as a user must be a member of both to gain access |
	| `gitrepo` | string | | https://github.com/alphagov/terraform-aws-re-build-jenkins.git | Git repo that hosts Dockerfile |
	| `gitrepo_branch` | string | | master | Branch of git repo that hosts Dockerfile |
	| `hostname_suffix` | string | **yes** | none | Main domain name for new Jenkins instances, eg. example.com |
	| `server_instance_type` | string | | t2.small | This defines the default master server EC2 instance type |
	| `server_name` | string | | jenkins2 | Hostname of the jenkins2 master |
	| `server_root_volume_size` | string | | 50 | Size of the Jenkins Server root volume (GB) |
	| `ssh_public_key_file` | string | **yes** | none | Location of public key used to access the server instances |
	| `team_name` | string | **yes** | none | Name of your team. This is used to construct the DNS name for your Jenkins instances |
	| `ubuntu_release` | string | | xenial-16.04-amd64-server | Which version of ubuntu to install |
	| `worker_instance_type` | string | | t2.medium | This defines the default worker server EC2 instance type |
	| `worker_name` | string | | worker | Name of the Jenkins2 worker |
	| `worker_root_volume_size` | string | | 50 | Size of the Jenkins worker root volume (GB) |

1. Initialise Terraform

	```
	terraform init \
	  -backend-config="region=$AWS_DEFAULT_REGION" \
	  -backend-config="key=re-build-systems.tfstate" \
	  -backend-config="bucket=tfstate-$JENKINS_TEAM_NAME-$JENKINS_ENV_NAME"
	```

1. Plan and Apply Terraform

	```
	terraform plan \
	  -var-file=./terraform.tfvars  \
	  -var environment=$JENKINS_ENV_NAME \
	  -var github_client_id=$JENKINS_GITHUB_OAUTH_ID \
	  -var github_client_secret=$JENKINS_GITHUB_OAUTH_SECRET \
	  -out terraform.plan
	```

	```
	terraform apply "terraform.plan"
	```

## Next Steps

* The Jenkins master and agent server have unrestricted outwards access to the internet, we suggest implementing an egress proxy, security groups etc to restrict access
* SSH access is available by `ssh -i /path/to/private.key ubuntu@[url]`

## Contributing

Refer to our [Contributing guide].

## Licence

[MIT License]

[architectural documentation]: https://github.com/alphagov/re-build-systems/tree/master/docs/architecture
[AWS Command Line Interface (CLI)]: https://aws.amazon.com/cli/
[Contributing guide]: https://github.com/alphagov/re-build-systems/blob/master/CONTRIBUTING.md
[Jenkins (version 2)]: https://jenkins.io/2.0/
[MIT License]: https://github.com/alphagov/re-build-systems/blob/master/LICENCE
[Register a new OAuth application]: https://github.com/settings/applications/new
[S3 bucket]: https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html
[Terraform]: https://www.terraform.io/intro/index.html
[terraform v0.11.7]: https://www.terraform.io/downloads.html

# Example configuration

## Prerequisites

Before you start you'll need:

* a basic understanding of how to use [Terraform]

* an AWS user account with administrator access

* [Terraform v0.11.7] installed on your laptop

* [AWS Command Line Interface (CLI)] installed on your laptop

## Provision DNS and Jenkins instances

1. Add your AWS user credentials to `~/.aws/credentials`. If this file does not exist, you'll need to create it.

	```
	[my-aws-profile]
	aws_access_key_id = [your aws key here]
	aws_secret_access_key = [your aws secret here]
	```

1. Change into the `examples/complete_deployment_of_dns_and_jenkins` directory

1. Rename the `terraform.tfvars.example` file to `terraform.tfvars`.

1. Edit the `terraform.tfvars` file to reflect the following configuration:

	| Name | Var Type | Required | Default | Description |
	| :--- | :--- | :--: | :--- | :--- |
	| `allowed_ips` | list | **yes** | none | A list of IP addresses permitted to access (via SSH & HTTPS) the EC2 instances created that are running Jenkins |
	| `aws_az` | string | | the first AZ in a region | Single availability zone to place master and worker instances in, eg. eu-west-1a |
	| `aws_profile` | string | | default aws profile in ~/.aws/credentials | AWS Profile (credentials) to use |
	| `aws_region` | string | | default aws region | AWS Region to use, eg. eu-west-1 |
	| `custom_groovy_script` | string | | none | Path to custom groovy script to run at end of initial jenkins configuration |
	| `environment` | string | **yes** | none | Environment name (e.g. production, test, ci). This is used to construct the DNS name for your Jenkins instances |
	| `github_admin_users` | list | | none | List of Github admin users (github user name) |
	| `github_client_id` | string | | none | Your Github Auth client ID |
	| `github_client_secret` | string | | none | Your Github Auth client secret |
	| `github_organisations` | list | | none | List of Github organisations and teams that users must be a member of to allow HTTPS login to master |
	| `gitrepo` | string | | https://github.com/alphagov/terraform-aws-re-build-jenkins.git | Git repo that hosts Dockerfile |
	| `gitrepo_branch` | string | | master | Branch of git repo that hosts Dockerfile |
	| `hostname_suffix` | string | **yes** | none | Main domain name for new Jenkins instances, eg. example.com |
	| `server_instance_type` | string | | t2.small | This defines the default master server EC2 instance type |
	| `server_name` | string | | jenkins2 | Hostname of the jenkins2 master |
	| `server_root_volume_size` | string | | 50 | Size of the Jenkins Server root volume (GB) |
	| `ssh_public_key_file` | string | **yes** | none | Location of public key used to access the server instances |
	| `team_name` | string | **yes** | none | Name of your team. This is used to construct the DNS name for your Jenkins instances |
	| `worker_instance_type` | string | | t2.medium | This defines the default worker server EC2 instance type |
	| `worker_name` | string | | worker | Name of the Jenkins2 worker |
	| `worker_root_volume_size` | string | | 50 | Size of the Jenkins worker root volume (GB) |

1. Set AWS environment variables

    If you're using bash, add a space at the start of `export AWS_ACCESS_KEY_ID` and `export AWS_SECRET_ACCESS_KEY` to prevent them from being added to `~/.bash_history`.

    ```
    export AWS_ACCESS_KEY_ID="[aws key]"
    export AWS_SECRET_ACCESS_KEY="[aws secret]"
    export AWS_DEFAULT_REGION="eu-west-1"
    ```

1. Create a GitHub OAuth app to allow you to setup authentication to the Jenkins through GitHub.

    Go to the [Register a new OAuth application] and use the following settings to setup your app.

    The [URL] will follow the pattern `https://[environment].[team_name].[hostname_suffix]`.  For example `https://dev.my-team.build.gds-reliability.engineering`

      * Application name:  `jenkins-[environment]-[team-name]` , e.g. `jenkins-dev-my-team`.

      * Homepage URL:  `[URL]`

      * Application description:  `Build system for [URL]`

      * Authorization callback URL:  `[URL]/securityRealm/finishLogin`

    Then, click the 'Register application' button.

    Export the credentials as they appear on the screen:

    If you're using bash, add a space at the start of `export JENKINS_GITHUB_OAUTH_ID` and `export JENKINS_GITHUB_OAUTH_SECRET` to prevent them from being added to `~/.bash_history`.

    ```
    export JENKINS_GITHUB_OAUTH_ID="[client-id]"
    export JENKINS_GITHUB_OAUTH_SECRET="[client-secret]"
    ```

1. Set Jenkins related environment variables

    ```
    export JENKINS_TEAM_NAME="my-team"
    export JENKINS_ENV_NAME="dev"
    ```

1. Create the [S3 bucket] to host the Terraform state file by running this command from the `tools` directory:

    ```
    ./create-s3-state-bucket \
      -t $JENKINS_TEAM_NAME \
      -e $JENKINS_ENV_NAME \
      -p [my-aws-profile]
    ```

1. Change back into the `examples/complete_deployment_of_dns_and_jenkins` directory

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
      -out my-plan.txt
    ```

    ```
    terraform apply \
      -var-file=./terraform.tfvars  \
      -var environment=$JENKINS_ENV_NAME \
      -var github_client_id=$JENKINS_GITHUB_OAUTH_ID \
      -var github_client_secret=$JENKINS_GITHUB_OAUTH_SECRET \
      my-plan.txt
    ```

## Contributing

Refer to our [Contributing guide].

## Licence

[MIT License]

[AWS Command Line Interface (CLI)]: https://aws.amazon.com/cli/
[Contributing guide]: https://github.com/alphagov/re-build-systems/blob/master/CONTRIBUTING.md
[MIT License]: https://github.com/alphagov/re-build-systems/blob/master/LICENCE
[Register a new OAuth application]: https://github.com/settings/applications/new
[S3 bucket]: https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html
[Terraform]: https://www.terraform.io/intro/index.html
[terraform v0.11.7]: https://www.terraform.io/downloads.html

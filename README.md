# How to provision a Jenkins build system

This repository provides the infrastructure code for provisioning a Jenkins build system. The build is a containerised [Jenkins (version 2)] platform on Amazon Web Services (AWS), consisting of a master node and an agent node. Once provisioned, users log into the Jenkins build using their Github account.

There are 3 initial steps to set up your Jenkins platform:

1. Provision the DNS infrastructure.

1. Configure and provision the main Jenkins infrastructure.

1. Sign into your new Jenkins and try it out.

You'll only need to provision the DNS infrastructure once and ask Reliability Engineering to enable your new domain, this may take up to 2 working days. Once this step is complete you can provision the main Jenkins infrastructure anytime you need to create a new environment.

Each environment you create will have a URL like this:

`https://jenkins2.[environment_name].[team_name].build.gds-reliability.engineering`

Read the [architectural documentation] for more information about the build system architecture. 

## Prerequisites

Before you start you'll need:

* a basic understanding of how to use [Terraform]

* an AWS user account with administrator access

* [Terraform v0.11.7] installed on your laptop

* [AWS Command Line Interface (CLI)] installed on your laptop

## Configure and provision the main Jenkins infrastructure

Provisioning the DNS infrastructure allows you to set up the URLs you will use to access your Jenkins.

You'll need to provision a separate Jenkins for each environment you want to create. For example, you might want separate development and production environments, these environments will have different URLs.

Start by provisioning the DNS for one environment, add other environments later. You'll also need to choose your team name, which will be part of the Jenkins URL.

1. Add your AWS user credentials to `~/.aws/credentials`

    If this file does not exist, you'll need to create it.

    ```
    [re-build-systems]
    aws_access_key_id = [your aws key here]
    aws_secret_access_key = [your aws secret here]
    ```
### Configure the DNS infrastructure

1. Clone this repository to a location of your choice.

1. Browse to the `terraform/dns` folder and rename `terraform.tfvars.example` to `terraform.tfvars`.

1. Edit the `terraform.tfvars` file from step 2 and customise the user settings under:

   `### CUSTOM USER SETTINGS ###`

1. Export the `team_name` as a variable to use when running the DNS Terraform

    ```
    export JENKINS_TEAM_NAME=[your team name as defined in the `terraform.tfvars` file]
    ```

1. Create an [S3 bucket] to hold the Terraform state file.

   Run this command from the `tools` directory:

    ```
    ./create-dns-s3-state-bucket \
        -d build.gds-reliability.engineering \
        -p re-build-systems \
        -t $JENKINS_TEAM_NAME
    ```

    If you receive an error, it may be because your `team_name` is not unique. Your team_name must be unique to ensure the associated URLs are unique. Go back to step 4 in Configure DNS, change your `team_name` and then continue from that point.

1. Export secrets

    To initialise the S3 bucket, you'll need to export secrets from the `~/.aws/credentials` file.

    If you're using bash, add a space at the start of `export AWS_ACCESS_KEY_ID` and `export AWS_SECRET_ACCESS_KEY` to prevent them from being added to `~/.bash_history`.

    ```
    export AWS_ACCESS_KEY_ID="[aws key]"
    export AWS_SECRET_ACCESS_KEY="[aws secret]"
    export AWS_DEFAULT_REGION="eu-west-1"
    ```

### Provision the DNS infrastructure

1.   Run these commands from the `terraform/dns` directory:

    ```        
    terraform init \
        -backend-config="region=$AWS_DEFAULT_REGION" \
        -backend-config="bucket=tfstate-dns-$JENKINS_TEAM_NAME.build.gds-reliability.engineering" \
        -backend-config="key=$JENKINS_TEAM_NAME.build.gds-reliability.engineering.tfstate"
    ```

    ```
    terraform apply -var-file=./terraform.tfvars
    ```

2. You'll get an output in your terminal like this:

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

    Send this output to reliability-engineering@digital.cabinet-office.gov.uk who'll make your URL live. This step may take up to two working days.

## Provision the main Jenkins infrastructure

*this section is quite long,  if possible we try and break up long lists of steps to make it easier for people. Is there anyway we could break these steps up into seperate parts?*

Once Reliability Engineering has made your URL live, you can provision the main Jenkins infrastructure.

You'll need to choose which environment you want to set up Jenkins for, for example `ci`, `dev` or `staging` which will form part of the Jenkins URL.

1. Export the environment and team names set during DNS provisioning:

    ```
    export JENKINS_ENV_NAME=[environment-name]
    export JENKINS_TEAM_NAME=[team-name]
    ```

1. Create a GitHub OAuth app to allow you to setup authentication to the Jenkins through GitHub.

    Go to the [register a new OAuth application] page and use the following settings to setup your app.

    The [URL] will follow the pattern `https://jenkins2.[environment-name].[team-name].build.gds-reliability.engineering`.

    * Application name:  `re-build-auth-[team name]-[environment name]` , for example `re-build-auth-app-eidas-dev`. You may have to depart from this format if it exceeds 34 characters.

    * Homepage URL:  [URL]

    * Application description:  Build system for [URL]

    * Authorization callback URL:  [URL]/securityRealm/finishLogin

    Then, click the 'Register application' button.

    Export the credentials as they appear on the screen:

    ```
    export JENKINS_GITHUB_OAUTH_ID=[client-id]
    export JENKINS_GITHUB_OAUTH_SECRET=[client-secret]
    ```

1. Transfer ownership of the Github OAuth app

    Skip this step if you're provisioning your platform for testing or development purposes. Otherwise you should transfer ownership of the app to `alphagov`.\
    
    To do this, click the "Transfer ownership" button located at the top of the page where you copied the credentials from and input `alphagov` as the organisation.

1. Generate an SSH key pair in a location of your choice. You can use this command to generate one:

    ```
    ssh-keygen -t rsa -b 4096 \
        -C "Key for Build System - team ${JENKINS_TEAM_NAME} - environment ${JENKINS_ENV_NAME}" \
        -f ~/.ssh/build_systems_${JENKINS_TEAM_NAME}_${JENKINS_ENV_NAME}_rsa
    ```

    The public key will be used in a later step.

    The private key will need to be shared amongst the team, to allow them to SSH into the servers.

1. In the `terraform/jenkins` folder, rename `terraform.tfvars.example` to `terraform.tfvars`.

1. Customise the `terraform.tfvars` file by editing the settings under `## CUSTOM USER SETTINGS - change these values for your custom Jenkins ###`

1. Create an S3 bucket to host the terraform state file by running this command from the `tools` directory:

    ```
    ./create-s3-state-bucket \
        -t $JENKINS_TEAM_NAME \
        -e $JENKINS_ENV_NAME \
        -p re-build-systems
    ```

1. To initialise the S3 bucket created with Terraform, you'll need to export some secrets.

    You did this in the `DNS provisioning` section of this guidance, so you'll only need to carry out this step if you ended your terminal session since you completed that step.

    ```
    export AWS_ACCESS_KEY_ID="[aws key]"
    export AWS_SECRET_ACCESS_KEY="[aws secret]"
    export AWS_DEFAULT_REGION="eu-west-1"
    ```

1. Run these commands from the `terraform/jenkins` directory:

    ```
    terraform init \
        -backend-config="region=$AWS_DEFAULT_REGION" \
        -backend-config="key=re-build-systems.tfstate" \
        -backend-config="bucket=tfstate-$JENKINS_TEAM_NAME-$JENKINS_ENV_NAME"
    ```
    
    If you did not use the suggested command to create the SSH key pair, make sure you change the following command to reflect the file path to your public SSH key:
    
    ```
    terraform apply \
        -var-file=./terraform.tfvars  \
        -var environment=$JENKINS_ENV_NAME \
        -var github_client_id=$JENKINS_GITHUB_OAUTH_ID \
        -var github_client_secret=$JENKINS_GITHUB_OAUTH_SECRET \
        -var ssh_public_key_file=~/.ssh/build_systems_${JENKINS_TEAM_NAME}_${JENKINS_ENV_NAME}_rsa.pub
    ```

    If you see `Error loading modules: bad response code: 401` when running the `terraform init` command,
    it may be due to the contents of your `.netrc` file. Temporarily renaming the file means `terraform` will ignore it.    

1. Use the new Jenkins by visiting the Jenkins at the URL shown by the output of the previous command (`jenkins2_url`).

### Debugging

*will people need to do any troubleshooting, or is debugging enough?*

To SSH into the master instance run:
```
ssh -i [path-to-the-private-ssh-key-you-generated] ubuntu@[jenkins2.my-env.my-team.build.gds-reliability.engineering]
```

To SSH into the agents instance you need to use the master node as a proxy, like so:
```
ssh -i [path-to-the-private-ssh-key-you-generated] -o ProxyCommand='ssh -W %h:%p ubuntu@[jenkins2.my-env.my-team.build.gds-reliability.engineering]' ubuntu@worker
```

Once logged in with the `ubuntu` user, you can switch to the root user by running `sudo su -`.

### Recommendations

*be good if we could give some reasons\benefits of doing these things*

Next, you may want to:

* enable AWS CloudTrail
* remove the generic SSH key used during provisioning and use personal keys
* remove the default `ubuntu` account from the AWS instance(s)


## Contributing

Refer to our [Contributing guide](CONTRIBUTING.md).

## Licence

[MIT License](LICENCE).

[architectural documentation]: docs/architecture/README.md
[Register a new OAuth application]: https://github.com/settings/applications/new
[Jenkins (version 2)]: https://jenkins.io/2.0/
[terraform v0.11.7]: https://www.terraform.io/downloads.html
[AWS Command Line Interface (CLI)]: https://aws.amazon.com/cli/
[Terraform]: https://www.terraform.io/intro/index.html
[S3 bucket]: https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html

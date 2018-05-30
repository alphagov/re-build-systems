# Reliability Engineering - Build Systems

This repository provides the infrastructure code for provisioning a containerised Jenkins instance on either a laptop or AWS.

## Contributing

Refer to our [Contributing guide](CONTRIBUTING.md).

## Architectural documentation

Architectural documentation is available [here](docs/architecture/README.md).

## Provisioning Jenkins2 on your laptop for development

Skip this section if you are just trying to provision a Terraform plaftorm to use for your project.

This will provision a Docker container running Jenkins2 on your laptop.

You need `docker` >= `v18.03.0`

```
cd docker
docker build -t="jenkins/jenkins-re" .
docker run --name myjenkins -v /var/run/docker.sock:/var/run/docker.sock -ti -p 8000:80 -p 50000:50000 jenkins/jenkins-re:latest
```
In the command above, the `-v` argument is optional, but needed if you want to start new docker containers on the host from within the Jenkins container (e.g. containers to run tests or build artifacts).

To access the instance browse to [here](http://localhost:8000)


For debugging, you can either:

* access container as jenkins user:
`docker exec -u 1000 -it myjenkins /bin/bash`

* access container as root user:
`docker exec -it myjenkins /bin/bash`


## Provisioning Jenkins2 on AWS

This will provision a containerized Jenkins instance on AWS.

1. Have the dependencies installed:

    * Terraform v0.11.7

    * `brew install awscli python3`

1. Configure your ~/.aws/credentials file with your own details:

    ```
    [re-build-systems]
    aws_access_key_id = AABBCCDDEEFFG
    aws_secret_access_key = abcdefghijklmnopqrstuvwxyz1234567890
    ```

    Be careful not to use quotes in the above.

1. Decide on an environment name, which will be referred as `[environment-name]` from now on.
That is usually something like `test`, `staging`, `production` or your name if you are doing development or testing (e.g. `daniele`).

1. Generate an SSH public/private key pair. This is just to bootstrap the provisioning process. 

1. Have a "config directory" for your sensitive data with this structure:

    ```
    |-- re-build-system            <-- this repository
    |-- re-build-system-config     <-- configuration folder
    |   |-- terraform
    |       |-- keys
    |       |-- terraform.tfvars

    ```
    
    If you are from GDS, you can checkout [this repo](https://github.com/alphagov/re-build-systems-config) as your config folder. 

1. Copy the **public** key you generated in the `re-build-system-config` folder, using this name: `re-build-systems-[environment-name]-ssh-deployer.pub`.

1. Customise the `terraform.tfvars` file.

1. Create S3 bucket to host terraform state file:

    ```
    cd [your_git_working_copy]
    terraform/tools/create-s3-state-bucket -b re-build-systems -e [environment-name] -p re-build-systems
    ```

1. Export secrets

    In order to initialise with Terraform the S3 bucket we have created, we need to export some secrets from the `~/.aws/credentials` file.

    ```
    export AWS_ACCESS_KEY_ID="someaccesskey"
    export AWS_SECRET_ACCESS_KEY="mylittlesecretkey"
    export AWS_DEFAULT_REGION="eu-west-2"
    ```

1. Run Terraform

    ```
    cd terraform
    terraform init -backend-config="region=eu-west-2" -backend-config="bucket=tfstate-re-build-systems-[environment-name]" -backend-config="key=re-build-systems.tfstate"
    terraform apply -var-file=../../re-build-systems-config/terraform/terraform.tfvars  -var environment=[environment-name]
    ```

      You should see output like this:
    
      >null_resource.get_public_dns_name (local-exec): public_dns name =  
      null_resource.get_public_dns_name (local-exec): [  
      null_resource.get_public_dns_name (local-exec):     <b>"ec2-11-222-333-444.us-east-1.compute.amazonaws.com"</b>  
      null_resource.get_public_dns_name (local-exec): ]  
      null_resource.get_public_dns_name: Creation complete after 1s (ID: 1111111111111111111)  
      aws_eip.jenkins2_eip: Creation complete after 1s (ID: eipalloc-11111111111111111)  
    
      >Apply complete! Resources: 19 added, 0 changed, 0 destroyed.  
    
      >Outputs:  
    
      >image_id = ami-11111111  
      jenkins2_eip = <b>11.222.333.444</b>  
      jenkins2_security_group_id = sg-11111111111111111  
      jenkins2_vpc_id = vpc-11111111111111111  
      public_subnets = [  
          subnet-11111111111111111  
      ]

1. Use the new Jenkins instance

    The previous `terraform apply` outputs some values. The most useful are the `jenkins2_eip` and `public_dns_name` (values of these are printed in bold in the example output above).

    * Visit the Jenkins installation at `http://[public_dns_name]` or `http://[jenkins2_eip]`

    * SSH into the instance with `ssh -i [path-to-your-private-ssh-key] ubuntu@[jenkins2_eip]`
        * To switch to the root user, run `sudo su -`

### Recommendations

This is a list of things you may consider doing next:

* implement HTTPS
* enable AWS CloudTrail
* remove the default `ubuntu` account from the AWS instance(s)


## Licence

[MIT License](LICENCE)

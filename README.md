_This repository is no longer being maintained and no enhancements nor security patches will be made. The repository is part of the [GDS Reliability Engineering Build System](https://github.com/alphagov/re-build-systems) which has been deprecated._

---

# How to provision a Jenkins build system

This repository provides examples for provisioning a Jenkins build system. The build is a containerised [Jenkins (version 2)] platform on Amazon Web Services (AWS), consisting of a master node and an agent node. Once provisioned, users log into the Jenkins build using their GitHub account.

Read the [architectural documentation] for more information about the build system infrastructure.

## Examples

This [Jenkins (version 2)] build system has been created by publishing 2 [Terraform] modules, which means you can pick and choose how you use it.

For ease, you can use either of these two examples (one for users within the Government Digital Service (GDS) and one for those outside of GDS) to provision a Jenkins build system.

Follow [this example](https://github.com/alphagov/re-build-systems/tree/master/examples/gds_specific_dns_and_jenkins) if you are from GDS, or [this one](https://github.com/alphagov/re-build-systems/tree/master/examples/complete_deployment_of_dns_and_jenkins) otherwise.

### Accessing the master and agent servers

To SSH into the master instance run:
```
ssh -i [path-to-the-private-ssh-key-you-generated] ubuntu@[my-env.my-team.build.gds-reliability.engineering]
```

To SSH into the agents instance you need to use the master node as a proxy, like so:
```
ssh -i [path-to-the-private-ssh-key-you-generated] -o ProxyCommand='ssh -W %h:%p ubuntu@[my-env.my-team.build.gds-reliability.engineering]' ubuntu@worker
```

Once logged in with the `ubuntu` user, you can switch to the root user by running `sudo su -`.

### Accessing the master Docker container

Once you have SSHed into the master server, run this command:

`docker exec -it myjenkins /bin/bash`

This gives you root access within the Docker container.

### Recommendations

Next, you may want to:

* enable AWS CloudTrail

  The benefit of this is that it adds auditing capabilities for changes to the AWS infrastructure. This adds a level of security, as changes to the infrastructure are captured in logs.

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

module "jenkins2_server" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "1.5.0"
  name                        = "${var.server_name}.${var.environment}.${var.hostname_suffix}"
  ami                         = "${data.aws_ami.source.id}"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.docker-jenkins2-server-template.rendered}"
  key_name                    = "jenkins2_key_${var.product}-${var.environment}"
  monitoring                  = true
  vpc_security_group_ids      = ["${module.jenkins2_security_group.this_security_group_id}"]
  subnet_id                   = "${element(module.jenkins2_vpc.public_subnets,0)}"

  root_block_device = [{
    volume_size           = "${var.server_root_volume_size}"
    delete_on_termination = "true"
  }]

  tags {
    Environment = "${var.environment}"
    ManagedBy   = "terraform"
    Name        = "jenkins2_ec2_${var.product}_${var.environment}"
    Product     = "${var.product}"
  }
}

# This is a work-around to get the public DNS name of the eip which is assigned to this EC2 instance. If we output the public_dns directly from
# the terraform-aws-modules/ec2-instance/aws module then it will be the DNS name that resolves to the original IPv4 address assigned to the EC2, rather than
# the eip. This may be resolved in Terraform (using an export from aws_eip) in the future at which point this code can be removed (see
# https://github.com/terraform-providers/terraform-provider-aws/issues/1149).
resource "null_resource" "get_public_dns_name" {
  triggers {
    cluster_instance_ids = "${join(",", module.jenkins2_server.id)}"
  }

  depends_on = ["module.jenkins2_server"]

  provisioner "local-exec" {
    command = "echo 'public_dns name = ' && /usr/local/bin/aws ec2 describe-instances --instance-ids ${join(" ", module.jenkins2_server.id)} --query 'Reservations[].Instances[].PublicDnsName'"
  }
}

data "aws_ami" "source" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.ubuntu_release}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "docker-jenkins2-server-template" {
  template = "${file("cloud-init/master-${var.ubuntu_release}.yaml")}"

  vars {
    dockerversion = "${var.dockerversion}"
    fqdn          = "${var.server_name}.${var.hostname_suffix}"
    gitrepo       = "${var.gitrepo}"
    hostname      = "${var.server_name}.${var.hostname_suffix}"
    region        = "${var.aws_region}"
  }
}

data "template_file" "github_oauth_plugin_script" {
  count = "${var.github_client_id != "" ? 1 : 0}"

  template = "${file("${var.github_oauth_config_script}")}"

  vars {
    github_client_id = "${var.github_client_id}"
    github_client_secret = "${var.github_client_secret}"
    github_admin_users = "${var.github_admin_users}"
  }
}

# Create file which will be copied to docker image by Dockerfile.
resource "local_file" "github_oauth_plugin_script_rendering" {
  count = "${var.github_client_id != "" ? 1 : 0}"
  
  content  = "${data.template_file.github_oauth_plugin_script.rendered}"
  filename = "${path.module}/docker/files/out/github_oauth_plugin_script.groovy"

  depends_on = ["data.template_file.github_oauth_plugin_script"]
}

resource "aws_ebs_volume" "jenkins2_server_storage" {
  availability_zone = "${var.aws_az}"
  size              = "${var.server_persistent_storage_size}"
  type              = "gp2"

  lifecycle {
    ignore_changes = ["size", "type"]
  }

  tags {
    Environment = "${var.environment}"
    ManagedBy   = "terraform"
    Name        = "jenkins2_ebs_${var.product}_${var.environment}"
    Product     = "${var.product}"
  }
}

resource "aws_volume_attachment" "jenkins2_server_storage_attachment" {
  device_name = "/dev/xvdf"
  volume_id   = "${aws_ebs_volume.jenkins2_server_storage.id}"
  instance_id = "${element(module.jenkins2_server.id,0)}"
}

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
    volume_size           = "${var.volume_size}"
    delete_on_termination = "true"
  }]

  tags {
    Environment = "${var.environment}"
    ManagedBy   = "terraform"
    Name        = "jenkins2_ec2_${var.product}_${var.environment}"
    Product     = "${var.product}"
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
  template = "${file("cloud-init/${var.ubuntu_release}.yaml")}"

  vars {
    dockerversion = "${var.dockerversion}"
    fqdn          = "${var.server_name}.${var.hostname_suffix}"
    gitrepo       = "${var.gitrepo}"
    hostname      = "${var.server_name}.${var.hostname_suffix}"
    region        = "${var.aws_region}"
  }
}

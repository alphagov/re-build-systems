locals {
  asg_jenkins2_extra_tags = [
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "ManagedBy"
      value               = "terraform"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "asg-${var.server_name}.${var.environment}.${var.team_name}.${var.hostname_suffix}"
      propagate_at_launch = true
    },
    {
      key                 = "Team"
      value               = "${var.team_name}"
      propagate_at_launch = true
    },
  ]
}

data "template_file" "jenkins2_asg_server_template" {
  template = "${file("${path.module}/cloud-init/server-asg-${var.ubuntu_release}.yaml")}"

  depends_on = ["aws_efs_file_system.jenkins2_efs_server"]

  vars {
    awsenv               = "${var.environment}"
    dockerversion        = "${var.dockerversion}"
    efs_file_system      = "${aws_efs_file_system.jenkins2_efs_server.id}"
    fqdn                 = "${var.server_name}.${var.environment}.${var.team_name}.${var.hostname_suffix}"
    gitrepo              = "${var.gitrepo}"
    gitrepo_branch       = "${var.gitrepo_branch}"
    hostname             = "${var.server_name}.${var.environment}.${var.team_name}.${var.hostname_suffix}"
    region               = "${var.aws_region}"
    github_admin_users   = "${join(",", var.github_admin_users)}"
    github_client_id     = "${var.github_client_id}"
    github_client_secret = "${var.github_client_secret}"
    github_organisations = "${join(",", var.github_organisations)}"
  }
}

resource "aws_launch_configuration" "lc_jenkins2_server" {
  name_prefix   = "lc-${var.server_name}.${var.environment}.${var.team_name}-"
  image_id      = "${data.aws_ami.source.id}"
  instance_type = "${var.instance_type}"

  # associate_public_ip_address = true
  user_data = "${data.template_file.jenkins2_asg_server_template.rendered}"
  key_name  = "jenkins2_key_${var.team_name}_${var.environment}"

  security_groups = ["${module.jenkins2_sg_asg_server_internet_facing.this_security_group_id}", "${module.jenkins2_sg_asg_server_internal.this_security_group_id}"]

  root_block_device = [{
    volume_size           = "${var.server_root_volume_size}"
    delete_on_termination = "true"
  }]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_jenkins2_server" {
  name_prefix               = "asg-${var.server_name}.${var.environment}.${var.team_name}-"
  launch_configuration      = "${aws_launch_configuration.lc_jenkins2_server.name}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = ["${module.jenkins2_vpc.public_subnets}"]
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1

  #  lifecycle {
  #    create_before_destroy = true
  #  }

  tags = ["${local.asg_jenkins2_extra_tags}"]
}

resource "aws_elb" "elb_jenkins2_server" {
  name = "elb-${var.server_name}-${var.environment}-${var.team_name}"

  security_groups = ["${module.jenkins2_sg_asg_server_internet_facing.this_security_group_id}", "${module.jenkins2_sg_asg_server_internal.this_security_group_id}"]

  subnets = ["${element(module.jenkins2_vpc.public_subnets,0)}"]

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${aws_acm_certificate.tls_certificate.arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    target              = "TCP:80"
    interval            = 60
  }

  tags {
    Environment = "${var.environment}"
    ManagedBy   = "terraform"
    Name        = "jenkins2_elb_${var.team_name}_${var.environment}"
    Team        = "${var.team_name}"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_to_elb" {
  autoscaling_group_name = "${aws_autoscaling_group.asg_jenkins2_server.id}"
  elb                    = "${aws_elb.elb_jenkins2_server.id}"
}

resource "aws_route53_record" "dns_record_asg" {
  zone_id = "${var.route53_team_zone_id}"
  name    = "asg.${var.environment}"
  type    = "A"

  alias {
    name                   = "${aws_elb.elb_jenkins2_server.dns_name}"
    zone_id                = "${aws_elb.elb_jenkins2_server.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dns_record_servername" {
  zone_id = "${var.route53_team_zone_id}"
  name    = "${var.server_name}.${var.environment}"
  type    = "A"

  alias {
    name                   = "${aws_elb.elb_jenkins2_server.dns_name}"
    zone_id                = "${aws_elb.elb_jenkins2_server.zone_id}"
    evaluate_target_health = true
  }
}

# Example file for a customer.

variable "environment" {
  type    = "string"
  default = "test"
}

variable "team_name" {
  type    = "string"
  default = "test9"
}

variable "aws_profile" {
  type    = "string"
  default = "re-build-systems"
}

variable "aws_region" {
  type    = "string"
  default = "eu-west-1"
}

# allowed_ips needs to be passed in via .vars file.
# ssh_public_key_file needs to be passed in via .vars file or via command line

module "terraform_dns" {
  source  = "../../modules/dns"
  version = "1.0.0"

  team_name = "${var.team_name}"

  top_level_domain_name = "build.gds-reliability.engineering"

  aws_region = "${var.aws_region}"
  aws_az     = "${var.aws_region}a"

  aws_profile = "${var.aws_profile}"
}

module "terraform" {
  source  = "../../modules/jenkins"
  version = "1.0.0"

  aws_region  = "${var.aws_region}"
  aws_az      = "${var.aws_region}a"
  aws_profile = "${var.aws_profile}"

  environment          = "test9"
  team_name            = "${var.team_name}"
  route53_team_zone_id = "${module.terraform_dns.team_zone_id}"
  hostname_suffix      = "build.gds-reliability.engineering"
  server_name          = "jenkins2"
  dockerversion        = "18.03.1~ce-0~ubuntu"
}

module "jenkins" {
  source  = "../../jenkins"
  version = "1.0.0"

  # Add the id of your subnet here. This also determines the VPC the Jenkins instances are created in.
  subnet_id = "${module.an_already_existing_vpc.public_subnets[0]}"

  # Note that the region in the next section must match the region of the VPC and the AZ must match the AZ of the subnet passed in above.
  aws_region  = "${var.aws_region}"
  aws_az      = "${var.aws_region}a"
  aws_profile = "${var.aws_profile}"

  environment          = "my-environment"
  team_name            = "${var.team_name}"
  route53_team_zone_id = "${module.terraform_dns.team_zone_id}"
  hostname_suffix      = "${var.base_domain_name}"
  server_name          = "jenkins2"
  dockerversion        = "18.03.1~ce-0~ubuntu"
}

module "terraform_dns" {
  source  = "../../dns"
  version = "1.0.0"

  team_name = "${var.team_name}"

  top_level_domain_name = "${var.base_domain_name}"

  aws_region = "${var.aws_region}"
  aws_az     = "${var.aws_region}a"

  aws_profile = "${var.aws_profile}"
}

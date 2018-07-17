# Example file for a team.

data "terraform_remote_state" "team_dns_and_eips" {
  backend = "s3"

  config {
    bucket = "${local.dns_bucket_name}"
    key    = "${local.dns_tfstate_file}"
    region = "${var.aws_region}"
  }
}

module "jenkins" {
  source  = "../../../jenkins"
  version = "1.0.0"

  # AWS region, keys, etc.
  aws_region  = "${var.aws_region}"
  aws_az      = "${var.aws_region}a"
  aws_profile = "${var.aws_profile}"

  # Environment configuration.
  environment = "test9"
  team_name   = "${var.team_name}"
  server_name = "jenkins2"
  allowed_ips = "${var.allowed_ips}"

  # Public key
  ssh_public_key_file = "${var.ssh_public_key_file}"

  # DNS configuration
  route53_team_zone_id = "${data.terraform_remote_state.team_dns_and_eips.team_zone_id}"
  hostname_suffix      = "${var.hostname_suffix}"

  # Default the user_data to default Ubuntu 16 and Jenkins configuration. Only override this if you know what you are doing.
  user_data     = ""
  dockerversion = "18.03.1~ce-0~ubuntu"
}

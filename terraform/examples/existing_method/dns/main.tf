# Example file for a team.

module "terraform_dns" {
  source  = "../../../dns"
  version = "1.0.0"

  team_name = "${var.team_name}"

  top_level_domain_name = "build.gds-reliability.engineering"

  aws_region = "${var.aws_region}"
  aws_az     = "${var.aws_region}a"

  aws_profile = "${var.aws_profile}"
}

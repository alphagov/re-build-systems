module "terraform_dns" {
  # The next line needs to be a link to where the DNS module has been downloaded.
  source  = "./dns_module"
  version = "1.0.0"

  team_name = "${var.team_name}"

  top_level_domain_name = "build.gds-reliability.engineering"

  aws_region = "${var.aws_region}"
  aws_az     = "${var.aws_region}a"

  aws_profile = "${var.aws_profile}"
}

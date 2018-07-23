# Example file for a customer.

variable "environment" {
  type    = "string"
  default = "test"
}

variable "team_name" {
  type    = "string"
  default = "myteam"
}

variable "aws_profile" {
  type    = "string"
  default = "re-build-systems"
}

variable "main_domain_name" {
  type        = "string"
  description = "Main domain name in which Jenkins subdomain is placed."
  default     = "build.gds-reliability.engineering"
}

variable "aws_region" {
  type    = "string"
  default = "eu-west-1"
}

locals {
  dns_bucket_name    = "tfstate-dns-${var.team_name}.${var.main_domain_name}"
  dns_tfstate_file   = "${var.team_name}.${var.main_domain_name}.tfstate"
  aws_default_region = "${var.aws_region}"
}

# allowed_ips needs to be passed in via .vars file.
# ssh_public_key_file needs to be passed in via .vars file or via command line


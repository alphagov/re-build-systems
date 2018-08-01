# Example file for a customer.

variable "environment" {
  type        = "string"
  description = "Environment name (e.g. production, test, ci). This is used to construct the DNS name."
}

variable "team_name" {
  type        = "string"
  description = "Name of your team. This is used to construct the DNS name."
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


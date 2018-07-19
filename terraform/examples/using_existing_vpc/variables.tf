variable "environment" {
  type    = "string"
  default = "test"
}

variable "team_name" {
  type    = "string"
  default = "my_team"
}

variable "aws_profile" {
  type    = "string"
  default = "re-build-systems"
}

variable "aws_region" {
  type    = "string"
  default = "eu-west-1"
}

variable "aws_az" {
  type    = "string"
  default = "eu-west-1a"
}

variable "base_domain_name" {
  description = "Main part of the domain name"
  type = "string"
  default = "build.gds-reliability.engineering"
}

# allowed_ips needs to be passed in via .vars file.
# ssh_public_key_file needs to be passed in via .vars file or via command line

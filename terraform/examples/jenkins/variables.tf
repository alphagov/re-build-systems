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

variable "allowed_ips" {
  type        = "list"
  description = "List of IP addresses which are permitted to access the server instances created."
}

variable "ssh_public_key_file" {
  type        = "string"
  description = "Location of public key used to access the server instances."
}

variable "hostname_suffix" {
  type        = "string"
  description = "Main domain name for new Jenkins instances, e.g. build.gds-reliability.engineering"
}

# S3 bucket that holds the terraform.tfstate file (given by the dns_tfstate_file variable) for the dns entries. This should be created by the terrform/dns module.
locals {
  dns_bucket_name  = "tfstate-dns-${var.team_name}.${var.hostname_suffix}"
  dns_tfstate_file = "${var.team_name}.${var.hostname_suffix}.tfstate"
}

# allowed_ips needs to be passed in via .vars file.
# ssh_public_key_file needs to be passed in via .vars file or via command line


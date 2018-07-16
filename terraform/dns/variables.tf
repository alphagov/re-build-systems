variable "aws_az" {
  type = "string"
}

variable "aws_profile" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "team_name" {
  description = "Team Name"
  type        = "string"
}

variable "top_level_domain_name" {
  description = "Top Level Domain name"
  type        = "string"
  default     = "build.gds-reliability.engineering"
}

variable "resource_prefix" {
  type        = "string"
  description = "Prefix for resources created in this module"
  default     = ""
}

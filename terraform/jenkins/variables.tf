# #### DNS preferences (from re-build-systems-dns)

variable route53_team_zone_id {
  type        = "string"
  description = "The Route53 zone id, obtained from re-build-systems-dns or elsewhere."
}

# #### AWS preferences ####

variable "allowed_ips" {
  type = "list"
}

variable "aws_az" {
  type    = "string"
  default = "eu-west-2a"
}

variable "aws_profile" {
  type        = "string"
  description = "AWS profile name from ~/.aws/credentials"
}

variable "aws_region" {
  type    = "string"
  default = "eu-west-2"
}

variable "instance_type" {
  type        = "string"
  description = "This defines the default (aws) instance type."
  type        = "string"
  default     = "t2.small"
}

variable "private_subnet" {
  type    = "string"
  default = "10.0.1.0/24"
}

variable "public_subnet" {
  type    = "string"
  default = "10.0.101.0/24"
}

variable "ssh_public_key_file" {
  type = "string"
}

# #### Team preferences ####

variable "environment" {
  description = "Environment (test, staging, production, etc)"
  type        = "string"
}

# #### Github preferences ####

variable "github_admin_users" {
  description = "List of Github admin users."
  type        = "list"
  default     = []
}

variable "github_client_id" {
  description = "Your Github client Id"
  type        = "string"
  default     = ""
}

variable "github_client_secret" {
  description = "Your Github client secret"
  type        = "string"
  default     = ""
}

variable "github_organisations" {
  description = "List of Github organisations."
  type        = "list"
  default     = []
}

variable "gitrepo" {
  type    = "string"
  default = "https://github.com/alphagov/re-build-systems.git"
}

variable "gitrepo_branch" {
  type    = "string"
  default = "master"
}

# #### Docker and Jenkins preferences ####

variable "dockerversion" {
  description = "Docker version to install"
  type        = "string"
}

variable "hostname_suffix" {
  type = "string"
}

variable "server_name" {
  description = "Name of the jenkins2 server"
  type        = "string"
}

variable "server_root_volume_size" {
  description = "Size of the Jenkins Server root volume (GB)"
  type        = "string"
  default     = "50"
}

variable "team_name" {
  description = "Team Name"
  type        = "string"
  default     = "team2"
}

variable "ubuntu_release" {
  description = "Which version of ubuntu to install on Jenkins Server"
  type        = "string"
  default     = "xenial-16.04-amd64-server"
}

variable "worker_instance_type" {
  description = "This defines the default (aws) instance type."
  type        = "string"
  default     = "t2.medium"
}

variable "worker_name" {
  description = "Name of the jenkins2 worker"
  type        = "string"
  default     = "worker"
}

variable "worker_root_volume_size" {
  description = "Size of the Jenkins Worker root volume (GB)"
  type        = "string"
  default     = "50"
}

# #### Advanced preferences ####

# Only touch these if you know what you're doing!
variable "user_data" {
  description = "Link to cloud init file containing setup information for Jenkins worker server instance. You do not need to set this - it defaults to a sensible value."
  type        = "string"
  default     = ""
}

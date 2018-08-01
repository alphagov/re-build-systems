output "environment" {
  value = "${var.environment}"
}

output "github_callback_url" {
  value = "${module.jenkins.github_callback_url}"
}

output "image_id" {
  value = "${module.jenkins.image_id}"
}

output "jenkins2_url" {
  value = "${module.jenkins.jenkins2_url}"
}

output "jenkins2_vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.jenkins.jenkins2_vpc_id}"
}

output "jenkins2_worker_public_ip" {
  description = "jenkins2 worker public ip address"
  value       = ["${module.jenkins.jenkins2_worker_public_ip}"]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.jenkins.public_subnets}"]
}

# output "team_domain_name" {
#   value = "${module.jenkins.team_domain_name}"
# }

output "team_zone_id" {
  value = "${module.jenkins.team_zone_id}"
}

output "team_zone_id" {
  value = "${module.terraform_dns.team_zone_id}"
}

output "team_zone_nameservers" {
  value = "${module.terraform_dns.team_zone_nameservers}"
}

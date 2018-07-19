output "team_domain_name" {
  value = "${var.team_name}.${var.top_level_domain_name}"
}

output "team_zone_id" {
  value = "${aws_route53_zone.primary_zone.zone_id}"
}

output "team_zone_nameservers" {
  value = "${aws_route53_zone.primary_zone.name_servers}"
}

resource "null_resource" "Instructions" {
  depends_on = ["aws_route53_zone.primary_zone"]

  provisioner "local-exec" {
    command = <<EOT
echo "\n*\n\nPlease send the following information to whichever team in your organisation looks after the domain name ${var.top_level_domain_name}: \n${var.team_name} = ['${join(".','", aws_route53_zone.primary_zone.name_servers)}.']\n\n*"
EOT
  }
}

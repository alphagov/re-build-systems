data "terraform_remote_state" "team_dns_and_eips" {
  backend = "s3"

  config {
    bucket = "tfstate-dns-${var.team_name}.${var.hostname_suffix}"
    key    = "${var.team_name}.${var.hostname_suffix}.tfstate"
    region = "${var.aws_region}"
  }
}

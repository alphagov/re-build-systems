data "template_file" "groovy_script" {
  template = "${file("${path.root}/${var.custom_groovy_script}")}"
}

module "jenkins" {
  source = "git::https://github.com/alphagov/terraform-aws-re-build-jenkins.git"

  # If a specific release is needed rather than "latest", the below syntax can be used.
  # source = "git::https://github.com/alphagov/terraform-aws-re-build-jenkins.git?ref=0.0.2"

  # Environment configuration.
  allowed_ips = "${var.allowed_ips}"
  az          = "${var.aws_az}"
  environment = "${var.environment}"
  region      = "${var.aws_region}"
  team_name   = "${var.team_name}"
  # Git repo
  gitrepo        = "${var.gitrepo}"
  gitrepo_branch = "${var.gitrepo_branch}"
  # Github auth configuration
  jenkins_admin_users_github_usernames = ["${join(",", var.jenkins_admin_users_github_usernames)}"]
  github_client_id                     = "${var.github_client_id}"
  github_client_secret                 = "${var.github_client_secret}"
  github_organisations                 = ["${join(",", var.github_organisations)}"]
  # Public key
  ssh_public_key_file = "${var.ssh_public_key_file}"
  # DNS configuration
  hostname_suffix      = "${var.hostname_suffix}"
  route53_team_zone_id = "${data.terraform_remote_state.team_dns.team_zone_id}"
  # Server Configuration
  custom_groovy_script    = "${data.template_file.groovy_script.rendered}"
  server_instance_type    = "${var.server_instance_type}"
  server_name             = "${var.server_name}"
  server_root_volume_size = "${var.server_root_volume_size}"
  append_server_user_data = "${var.append_server_user_data}"
  # Worker Configuration
  worker_instance_type    = "${var.worker_instance_type}"
  worker_name             = "${var.worker_name}"
  worker_root_volume_size = "${var.worker_root_volume_size}"
  append_worker_user_data = "${var.append_worker_user_data}"
}

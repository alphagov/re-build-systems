# Example file for creating an S3 bucket then provisioning the dns infrastructure, storing the state in this bucket.
resource "aws_s3_bucket" "dns_bucket" {
  bucket = "${local.dns_bucket_name}"

  versioning {
    enabled = true
  }

  provisioner "local-exec" {
      command = <<EOT
      cd dns && \
      sleep 20 && \
      terraform init \
      -backend-config="region=${local.aws_default_region}" \
      -backend-config="bucket=${local.dns_bucket_name}" \
      -backend-config="key=${local.dns_tfstate_file}" && \
      terraform plan -out latest_plan.out
    EOT
  }

  tags {
    ManagedBy = "terraform"
    Name      = "${var.team_name}.${var.main_domain_name}.dns"
    Team      = "${var.team_name}"
  }
}

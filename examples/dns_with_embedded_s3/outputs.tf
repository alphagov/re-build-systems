output "bucket_name" {
  value = "${aws_s3_bucket.dns_bucket.bucket_domain_name}"
}

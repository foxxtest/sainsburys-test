output "s3_bucket_url" {
  value = "${aws_s3_bucket.b.bucket_domain_name}"
}

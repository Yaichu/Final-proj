provider "aws" {
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  region     = var.region
}

resource "aws_s3_bucket" "bucket" {
  bucket = "fin-project-bucket"
#   acl    = "private"

  tags = {
    Name        = "project bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "access" {
  bucket = "${aws_s3_bucket.bucket.id}"

  block_public_acls   = true
  block_public_policy = false
}
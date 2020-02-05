provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "a" {
  bucket = "pipelineraw"
  acl    = "private"

  tags = {
    Name        = "Raw Data Bucket"
    Environment = "Dev"
  }
}

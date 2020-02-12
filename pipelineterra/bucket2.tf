resource "aws_s3_bucket" "b" {
  bucket = "pipelinecur"
  acl    = "private"

  tags = {
    Name        = "Curated Data Bucket"
    Environment = "Curated"
  }
}

resource "aws_s3_bucket" "c" {
  bucket = "terrafilestore"
  acl = "private"

  tags = {
    Name = "File Store Bucket"
    Environment = "File"
  }
}

terraform {
  backend "s3" {
    bucket = "terrafilestore"
    key = "terraform.tfstate"
    region = "eu-west-2"
  }
}

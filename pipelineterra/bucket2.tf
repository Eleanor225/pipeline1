resource "aws_s3_bucket" "b" {
  bucket = "pipelinecur"
  acl    = "private"

  tags = {
    Name        = "Curated Data Bucket"
    Environment = "Curated"
  }
}

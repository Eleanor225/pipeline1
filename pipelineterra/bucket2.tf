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

resource "aws_sns_topic" "curated_updates" {
  name = "curated-updates-topic"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
      "Sid":"s3-event-notifier",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
        },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:eu-west-2:460346970906:curated-updates-topic",
      "Condition":{
        "ArnLike":{
          "aws:SourceArn":"${aws_s3_bucket.b.arn}"
        }
      }
    },
    {
      "Sid":"1",
      "Effect":"Allow",
      "Principal":{
        "AWS":"arn:aws:iam::282654190546:user/51ml-s-iess4386"
      },
      "Action":["sns:Subscribe"],
      "Resource":["arn:aws:sns:eu-west-2:460346970906:curated-updates-topic"]
    }]
}
POLICY
}

resource "aws_s3_bucket_notification" "curbucket_notification" {
  bucket = aws_s3_bucket.b.id

  topic {
    topic_arn = aws_sns_topic.curated_updates.arn
    events = ["s3:ObjectCreated:*"]
  }
}
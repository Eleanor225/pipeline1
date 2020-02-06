provider "aws" {
  region = "eu-west-2"
}

resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {
            "Service": "s3.amazonaws.com"
            },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:user-updates-topic",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.a.arn}"}
        }
    }]
}
POLICY
}

resource "aws_s3_bucket" "a" {
  bucket = "pipelineraw"
  acl    = "private"

  tags = {
    Name        = "Raw Data Bucket"
    Environment = "Raw"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.a.id}"

  topic {
    topic_arn = "${aws_sns_topic.user_updates.arn}"
    events = ["s3:ObjectCreated:*"]
  }
}

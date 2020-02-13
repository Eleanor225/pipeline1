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

resource "aws_sns_topic" "cur_updates" {
  name = "cur-updates-topic"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {
            "Service": "s3.amazonaws.com"
            },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:cur-updates-topic",
        "Condition":{
            "ArnLike":{
              "aws:SourceArn":"${aws_s3_bucket.b.arn}"
            }
        }
    }]
}
POLICY
}

resource "aws_s3_bucket_notification" "cur_bucket_notification" {
  bucket = aws_s3_bucket.b.id

  topic {
    topic_arn = aws_sns_topic.cur_updates.arn
    events = ["s3:ObjectCreated:*"]
  }
}

resource "aws_sqs_queue" "cur_queue" {
  name = "cur_queue"
  delay_seconds = 0
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 10
  visibility_timeout_seconds = 300

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:cur_queue",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.cur_updates.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "cur_sqs" {
  topic_arn = aws_sns_topic.cur_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.cur_queue.arn
  filter_policy = ""
  raw_message_delivery = "true"
}
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
# Create snowflake user
resource "aws_iam_user" "snowflake_user" {
  name = "snowflake_user"
}

# Create role for snowflake access
resource "aws_iam_role" "iam_for_snowflake" {
  name = "iam_for_snowflake"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::282654190546:user/51ml-s-iess4386"
      },
      "Effect": "Allow",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "LR97355_SFCRole=2_/V0vCt2Vmzdp0mI4ZFxikzJTgSI="
        }
      }
    }
  ]
}
EOF
}
# Create snowflake access policy
resource "aws_iam_policy" "sf_policy" {
  name = "snowflake_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
      ],
      "Resource": "arn:aws:s3:::pipelinecur/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::pipelinecur"
    }
  ]
}
EOF
}
# Attach policy to role
resource "aws_iam_role_policy_attachment" "attach_sf" {
  role = aws_iam_role.iam_for_snowflake.name
  policy_arn = aws_iam_policy.sf_policy.arn
}
# Attach policy to user
resource "aws_iam_user_policy_attachment" "attach_user_sf" {
  user = aws_iam_user.snowflake_user.name
  policy_arn = aws_iam_policy.sf_policy.arn
}

# Create sns topic
resource "aws_sns_topic" "cur_updates_sf" {
  name = "cur-sf-updates-topic"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::282654190546:user/51ml-s-iess4386"
      },
      "Action": "SNS:Subscribe",
      "Resource": "arn:aws:sns:*:*:cur-sf-updates-topic"
    },
    {
      "Sid": "2",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:*:*:cur-sf-updates-topic",
      "Condition": {
        "ArnLike": [
          {
            "AWS:SourceArn": "${aws_s3_bucket.b.arn}"
          },
          {
            "AWS:SourceOwner":"${aws_iam_user.snowflake_user.arn}"
          }
        ]
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_notification" "cur_bucket_notification" {
  bucket = aws_s3_bucket.b.id

  topic {
    topic_arn = aws_sns_topic.cur_updates_sf.arn
    events = ["s3:ObjectCreated:*"]
  }
}
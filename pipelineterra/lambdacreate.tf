resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name = "sqs_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
         "sqs:DeleteMessage",
         "sqs:GetQueueAttributes",
         "sqs:ReceiveMessage"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:sqs:*"
    },
    {
      "Action" : [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_sqs" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.policy.arn
}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_file  = "../pipelineproj/lambdascript.py"
    output_path = "lambda_zip.zip"
}

resource "aws_lambda_function" "copy_file" {
  function_name = "sns-sqs-copyfile"
  filename = "lambda_zip.zip"
  handler = "lambdascript.lambda_handler"
  runtime = "python3.7"
  role = aws_iam_role.iam_for_lambda.arn
  memory_size = 1024
  timeout = 5
  source_code_hash = "data.archive_file.lambda_zip.output_base64sha256"
}

resource "aws_lambda_permission" "sqs" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "sns-sqs-copyfile"
  principal = "sqs.amazonaws.com"
  source_arn = aws_sqs_queue.queue.arn
}

resource "aws_lambda_event_source_mapping" "lambda" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name = aws_lambda_function.copy_file.arn
}

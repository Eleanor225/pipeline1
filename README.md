# Pipeline Project

This pipeline has been setup to explore the techniques for automating the data migration process using aws and snowflake services.

## Techniques/Methods Used:

Circleci for continuous integration of changes to code
Terraform for creating the infrastructure in AWS 
AWS CLI to put objects in the s3 raw bucket triggering the pipeline
Python to write the lambda function
Snowflake to create the snowpipe and flatten json data into a table

## Step 1
### Raw Data Bucket to SNS to SQS

Terraform code creates s3 bucket "pipelineraw" and the SNS associated with the bucket. The SNS topic requires publishing permission to be able to send messages to a queue, the SNS topic is also set up to respond to the event: "s3:ObjectCreated:*".
The SQS is set up with the policy SQS:SendMessage and is linked to the SNS topic ARN. Finally an SNS SQS subscription resource is created to set up the relationship between notification and queue.

Refer to pipelineterra/bucket1.tf

## Step 2
### Lambda Function and Python Script

The process follows raw bucket -> SNS -> SQS currently and requires the SQS message to trigger a lambda function which copies the file from raw to curated.
The terraform script lambdacreate.tf uses the contents of lambdascript.py to create the lambda function. 
An iam role for lambda is created and policies which allow SQS links and logs to be made are attached to the role. The terraform script zips the python code and uses it to create the lambda function. Finally a resource is made which gives permission for SQS messages to invoke the lambda function and the queue is mapped to the lambda function.

Refer to pipelineproj/lambdascript.py
	 pipelineterra/lambdacreate.tf

## Step 3
### Curated Bucket and SNS to Snowflake

Another terraform script creates the second bucket for the curated data and a bucket to store the terraform state file. The backend for s3 is set to the tfstate file in the bucket. Following this we need to set up the notification that will trigger the snowpipe in snowdflake. This is where another SNS topic is created with permissions that allow it to interact with snowflake. 

Refer to pipelineterra/bucket2.tf

## Step 4
### CircleCI

The config.yml file is used with CircleCI to integrate changes to the code automatically every time commits are made to Git. 

Refer to .circleci/config.yml

## Step 5
### Set up Snowflake Snowpipe 

The snowpipe was created in a worksheet in Snowflake. When the script is run it takes a file from the stage and transforms the json file into its separate components.


from __future__ import print_function

import boto3
import json
import time
import urllib.parse

print("Loading function")

s3 = boto3.client('s3')
bucket = "pipelineraw"
key = "colours4.json"
target_bucket = "pipelinecur"
copy_source = {'Bucket': bucket, 'Key': key}

def lambda_handler(event, context):
    response = s3.get_object(Bucket=bucket, Key=key)
    s3.copy_object(Bucket=target_bucket, Key=key, CopySource=copy_source)

import boto3
import ast


def lambda_handler(event, context):
    s3 = boto3.client('s3')
    # Accesses the message portion of the SNS from dicts and list
    sns_message = ast.literal_eval(event['Records'][0]['Sns']['Message'])
    #
    target_bucket = context.function_name
    # Accesses the name of the bucket the SNS was triggered from (which is inside the message part of the SNS)
    # and labels this the source
    source_bucket = str(sns_message['Records'][0]['s3']['bucket']['name'])
    # The key is the name of the object that has been uploaded to the bucket (which we want to copy)
    key = str(sns_message['Records'][0]['s3']['object']['key'])
    # Creates a dict with the details of the object we want to copy
    copy_source = {'Bucket': source_bucket, 'Key': key}
    # Prints the progress of the copying process
    print("Copying %s from bucket %s to bucket %s ..." % (key, source_bucket, target_bucket))
    # Tells s3 to copy the imported file into the target bucket with the same name as before (key)
    s3.copy_object(Bucket=target_bucket, Key=key, CopySource=copy_source)

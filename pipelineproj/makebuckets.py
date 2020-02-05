import boto3

# Creating the s3 client
s3 = boto3.client('s3')

# Creating current bucket list
bucket_list = s3.list_buckets()

# Making a list of the bucket names on my AWS account
bucket_names = []
for i in range(0, len(bucket_list['Buckets'])):
    bucket_names.append(bucket_list['Buckets'][i]['Name'])
print(bucket_names)
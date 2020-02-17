# Pipeline Project

This pipeline has been setup to explore the techniques for automating the data migration process using aws and snowflake services.

## Techniques/Methods Used:

Circleci for continuous integration of changes to code
Terraform for creating the infrastructure in AWS 
AWS CLI to put objects in the s3 raw bucket triggering the pipeline
Python to write the lambda function
Snowflake to create the snowpipe and flatten json data into a table



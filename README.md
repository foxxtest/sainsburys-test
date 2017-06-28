# sainsburys-test
# 
---
## Instructions

  * Created quickly using Terraform v0.9.9
  * terraform plan ; terraform apply
  * The bucket_url is an output
  * AWS Credentials need to be set, in a production setup i'd use LDAP linked based Vault creds
  * I've not included key secrets here, would recommend vault for that - so adapt to use an existing AWS key

## Observations

  * Unsure if brief required only the contents of sample_submission.bz2 or all files.
  * If I had opportunity to ask questions and understand the scope better,  I would have asked if the Dataset should be hosted on the EC2 instance and serviced via Nginx , but as the scope didn't state that I have s3 sync'd the dataset to a bucket
  * In a production sense , I'd do this completely differently.  I'd already have a set of terraform modules and rely on Terraform state to both create the ec2 instance to a standards template and to refer to state for VPC's/SG's etc etc - this is just a quick Terraform
  * url is http://sainsburys-test.s3.amazonaws.com/index.html

Jonathan Foxx 2017

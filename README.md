# Put-on-S3

The terraform project in question is designed to add an object to an S3 bucket using an EC2 instance.
The sequence of necessary steps is briefly presented below։
1.Connecting to an EC2 instance using an SSH client
2.Run the "aws configure" command. We can enter the "region" as desired from the requested values. However, we should definitely omit "access_key" and "secret_access_key" for security reasons.
3.To make sure that the configuration performed in the s3 part works, we can run the "aws s3 ls" command to view the list of buckets that exist in S3
4.Then we will create a new arbitrary file and add it to the target S3 bucket using the following command։
	"aws s3 cp <file_name> s3://<existing_s3_bucket_name>"

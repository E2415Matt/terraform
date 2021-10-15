# this task is to automate launching jenkins on an ec2 and restoring jenkins data from an s3 bucket and running the jenkins with restored data set

## stage 0 - jenkins container running on jenkins environment and jenkins data daily backed up to an s3 bucket using a jenkins job.
### jenkins data rest in jenkins-daily-backup-files bucket
### s3 and ec2 will in the same account

## stage 1 - Setup Bitbucket Actions to run Terraform

## stage 2 - terraform script for:
### main: launch 1 vpc, 1 public subnet, ec2, security group, machine image, etc
### network: internet gateway, cidr, route table, associate, etc
### s3: data of s3 bucket arn, s3 endpoint, etc
### variables: ip range, etc
### user data: instalL & enable docker, install docker-compose, install jenkins, install aws cli, clone repo from bitbucket, and run docker compose file, copy backup file from s3 bucket and paste it to jenkins container's volume, etc
### terraform: copy jenkins backup data from s3 bucket (jenkins-daily-backup-files) to volume of jenkins container on ec2
### output: ec2 public ip address, etc

## stage 3 - copy and paste <ec2 ip address:8080> to internet browser, and enter jenkins credentials

# Create EC2 and install docker, docker-compose and jenkins with terraform on AWS

# Restore jenkins files from S3 with/wo terraform
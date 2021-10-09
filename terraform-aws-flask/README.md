# technical project for deploying flask on aws using terraform as infrastructure as code

## prerequisites
### docker
### terraform
### aws account with aws-cli installed and configured

# how to:

# stage 1- if you are using vs code, it is good to have hashicorp, python, etc. extentions

# stage 2- define main resources such as public cloud provider aws, aws region, vpc, elastic container service, etc.
## you may use fargate or ec2 instance for the cluster. this time we are using fargate 
## so that we take advantage of fully managed service

# stage 3- define network

# stage 4- rds

# stage 5- alb

# stage 6- variables

# stage 7- outputs

# stage 8- deploy
$ cd /terraform-aws-flask/terraform
$ terraform init
$ terraform plan
$ terraform apply -auto-approve

# stage 9- copy alb dns name from screen and paste to internet browser

# stage 10- enter a name

# stage 11- in order to avoid aws charges delete all resources
$ terraform destroy

# stage 12- copy files to your local repo then
$ git add .
$ git commit -m "your short comment for this particular commit which will show on top of github repo"
$ git push

### folders are src and terraform, content as follows:
### src:
### contains a python flask application, which is connected to postgres database (aws console > rds )
### the application was updated to utilize "threads" and "js polling" for long-running background tasks
### terraform:
### contains the terraform script to deploy the flask application into aws fargate
### infrastructure components are all automatically provisioned when terraform apply command is run. please make sure to run terraform commands from terraform folder

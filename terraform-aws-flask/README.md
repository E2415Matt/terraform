# technical project for deploying flask on aws using terraform

### terraform: terraform is an open-source infrastructure as code software tool by hashi corp. terraform is a tool to build, change and manage infrastructure. terraform codifies cloud APIs into declarative configuration files. You can use terraform to manage environments with a configuration language called the hashicorp configuration language (hcl) for human-readable, automated deployments.
### please see: https://medium.com/clarusway/popular-devops-tools-review-ee0cffea14ec

## prerequisites
### docker
### terraform
### aws account with aws-cli installed and configured

# how to:

# stage 1- editor: if you are using vs code, it is good to have hashicorp, python, etc. extentions

# stage 2- terraform:

## main: define main resources such as public cloud provider aws, aws region, vpc, elastic container service, etc.
### you may use fargate or ec2 instance for the cluster. 
### this time we are using fargate so that we take advantage of fully managed elastic container service
### aws fargate lets you execute containers without needing to manage servers or clusters. amazon charges for used memory and virtual cpu resources to run fargate.
### please see: https://medium.com/clarusway/popular-devops-tools-review-ee0cffea14ec

## network: define network particulars. cidr block for vpc. we are deploying public and private subnets (2 each). database layer will be in private subnet and application will be in public subnet. public subnet will be connected to internet via internet gateway. private subnets will only be accesable from public subnets. 

## rds:postgres database with t2 micro instance.

## alb: elastic load balancer / application load balancer will be content delivery point. 

## variables: all the variables in one place. (e.g. cdir, port, instance type, etc.)

## outputs: once terraform apply run and resources deployed, dns name will be printed on screen, we will copy and paste the same to internet browser to reach our flask app online.

# stage 3- deploy
$ cd /terraform-aws-flask/terraform
$ terraform init
$ terraform plan
$ terraform apply -auto-approve

# stage 4- copy alb dns name from screen and paste to internet browser

# stage 5- enter a name

# stage 6- in order to avoid aws charges delete all resources
$ terraform destroy

# stage 7- copy files to your local repo then
$ git add .
$ git commit -m "your short comment for this particular commit which will show on top of github repo"
$ git push

### folders are src and terraform, content as follows:
### src:
### contains a python flask application, which is connected to postgres database (aws console > rds )
### terraform:
### contains the terraform script to deploy the flask application into aws fargate
### infrastructure components are all automatically provisioned when terraform apply command is run. please make sure to run terraform commands from terraform folder where main.tf file located.

provider "aws" {
  region = "eu-west-2"
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance"
  
  ami                    = "ami-0dbec48abfe298cab"
  instance_type          = "t2.micro"
  key_name               = "<name of your pem file>"
  monitoring             = true
  vpc_security_group_ids = ["sg-05ab0d02b04a40b1c"]
  subnet_id              = "subnet-a65a3fdc"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
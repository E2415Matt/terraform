# most organisations use their own scripts from github or bitbucket 
# or they use their private repos to pull images to run their custamized jenkins
# therefore part of this script commented out 
# these commented out parts show how you can install jenkins from public repos
# so that you can see options for both centos and ubuntu setup
# in case you are installing the jenkins for the first time
# and you do not need to have customised jenkins


# public cloud provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# configure the aws provider region
provider "aws" {
  region = "eu-west-2"
}

# create a vpc
resource "aws_vpc" "jenkins" {
  cidr_block = "10.0.0.0/16"
}

# chose operating system for jenkins instance
data "aws_ami" "amazon-linux-2" {
 most_recent = true


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

#data "aws_ami" "cent" {
#  most_recent = true
#
#  filter {
#
#    name   = "name"
#    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  owners = ["123456789012"] # Canonical
#}

# create instance and determine size of the server
resource "aws_instance" "jenkins" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.jenkins.name]
  key_name        = "aws3-london"

  # Install jenkins (for centos)
#  provisioner "remote-exec" {
#    inline = [
#      "sudo yum -y update",
#      "sudo yum -y install wget",
#      "echo 'Install Java JDK 8'",
#      "sudo yum remove -y java",
#      "sudo yum install -y java-1.8.0-openjdk",
#      "echo 'Install Maven'",
#      "sudo yum install -y maven",
#      "echo 'Install git'",
#      "sudo yum install -y git",
#      "echo 'Install Docker engine'",
#      "sudo yum update -y",
#      "sudo yum install docker -y",
#      "sudo sudo chkconfig docker on",
#      "echo 'Install Jenkins'",
#      "sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo",
#      "sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key",
#      "sudo yum install -y jenkins",
#      "sudo usermod -a -G docker jenkins",
#      "sudo chkconfig jenkins on",
#      "echo 'Start Docker && Jenkins services'",
#      "sudo service docker start",
#      "sudo service jenkins start"
#    ]
#  }
#
  # Install dependencies + jenkins (for ubuntu)
# provisioner "remote-exec" {
#   inline = [
#     "sudo apt update -y",
#     "sudo apt install --yes wget htop default-jre build-essential make python-minimal",
#     "curl https://get.docker.com | sh",
#     "sudo usermod -aG docker ubuntu",
#
#     # Prevent jenkins to start by itself
#     "echo exit 101 | sudo tee /usr/sbin/policy-rc.d",
#
#     "sudo chmod +x /usr/sbin/policy-rc.d",
#     "wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -",
#     "echo deb https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list",
#     "sudo apt update",
#     "sudo apt install --yes jenkins",
#     "sudo rsync -av --progress --update /home/ubuntu/jenkins/ /efs/jenkins",
#   ]
# }

  # Start jenkins (for ubuntu)
#  provisioner "remote-exec" {
#    inline = [
#      "sudo chown jenkins /tmp/clientid",
#      "sudo chown jenkins /tmp/clientsecret",
#      "sudo chown jenkins /tmp/userauthtoken",
#      "sudo chown jenkins /tmp/githubwebhooksecret",
#      "sudo chown jenkins /tmp/dnsimple_token",
#      "sudo cp /home/ubuntu/jenkins.default /etc/default/jenkins",
#      "sudo systemctl daemon-reload",
#      "sudo systemctl restart jenkins",
#      "echo applied default file",
#    ]
#  }

  # Install jenkins and open 8080 port (for ubuntu)
#  provisioner "remote-exec" {
#    inline = [
#      "sudo apt install wget -y",
#      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
#      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
#      "sudo apt update -qq",
#      "sudo apt install -y default-jre",
#      "sudo apt install -y jenkins",
#      "sudo systemctl start jenkins",
#      "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080",
#      "sudo sh -c \"iptables-save > /etc/iptables.rules\"",
#      "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
#      "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
#      "sudo apt-get -y install iptables-persistent",
#      "sudo ufw allow 8080",
#    ]
#  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user" # "ubuntu"
    private_key = file("~/aws3-london.pem")
  }

  tags = {
    "Name"      = "Jenkins_Server"
    "Terraform" = "true"
  }
}
# set open ingress ports rules 
variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22]
}

# launch security group of the instance
resource "aws_security_group" "jenkins" {
  name        = "Jenkins - Allow web traffic"
  description = "Allow ssh and standard http/https ports inbound and everything outbound"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}

# this hands on practise notes is about a task regarding provisioning highly available wordpress cluster on kubernetes.

# during previous knowledge sharing sessions about kubernetes,
# first we have run kubernetes clusters on bare metal contabo servers with ubuntu 20.04 operating system and used only linux / kubernetes commands to create and run our applications. if you have missed the session please refer to: https://medium.com/clarusway/kubernetes-step-by-step-setup-guide-for-beginners-cba307250a6c

# during second session we have used portainer on bare metal contabo servers. if you have missed the session please refer to: https://medium.com/clarusway/portainer-experiment-notes-ac1f9d88ea18

# third one was running wordpress + sql on google cloud platform's google kubernetes engine and we have used both gcp console's cloud shell and editor. if you have missed the session please refer to: (i will add the link (either medium or github) in due course)

# this time we will use aws eks cluster and deploy kubernetes wordpress infrastructure on it using terraform. we will utilise teraform to so that you can make small changes to the used .tf files and use the same scenario for your choice of public cloud provider in the future.



1- spin up an ec2 server instance

# we shall be using amazon web services (aws) resources. if you do not have one, please open a free account with aws at: https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=categories%23compute&trk=ps_a134p000006gB2SAAU&trkCampaign=acq_paid_search_brand&sc_channel=PS&sc_campaign=acquisition_GB&sc_publisher=Google&sc_category=Cloud%20Computing&sc_country=GB&sc_geo=EMEA&sc_outcome=acq&sc_detail=aws%20cloud&sc_content=Cloud%20Hosting_e&sc_matchtype=e&sc_segment=474715113292&sc_medium=ACQ-P%7CPS-GO%7CBrand%7CDesktop%7CSU%7CCloud%20Computing%7CSolution%7CGB%7CEN%7CText&s_kwcid=AL!4422!3!474715113292!e!!g!!aws%20cloud&ef_id=CjwKCAjwp_GJBhBmEiwALWBQk_q5MqVM2G_Vq4MJrUmVrCcnSHDP-V40snAr5VFjTs4CloPgrVxWDxoC698QAvD_BwE:G:s&s_kwcid=AL!4422!3!474715113292!e!!g!!aws%20cloud

# aws allows you to use some of the resources for free for 12 months for each new account and the same should be plenty enough for this task.

# open your aws management console make sure that you are at the right region. we will use london (eu-west-2) for this task.
# type eks in the search bar, click cluster on the left hand side. cluster count should show (0)
# type ec2 in the search bar, click instances on the left hand side and see that you do not have any instances in this region.

# prepare cloudformation yaml file to spin an ec2 to run terraform. user data in cloudformation file will install terraform. you may chose to do the same from commanline once ec2 started and connected to the instance
$ vim terraform-cloudformation-yum.yaml

# go to console and select cloudformation either via services or via search bar. click: create stack, with new resources, template is ready, upload a template file. you can use json or yaml files. we have yaml file (terraform-cloudformation-yum.yaml). upload the file (and then you may view in designer or you can click next), you may name the stack terra, and select name of your .pem file from the pull down list, and click create stack. you may follow the progress on cloudofrmation > stacks page or you can also check from ec2 page. once ec2 up and running, take connect / ssh details and make remote ssh connection to the newly spinned instance.
$ ssh -i "<your .pem file name>" ec2-user@ec2-18-170-51-34.eu-west-2.compute.amazonaws.com
# (or if you are using vscode, you may use remote ssh as well)

# you will need to have unzip, terrafrom, aws cli and kubectl installed.

# unzip and terraform installed during execution of cloudformation of user data
# awscli: please enter access key, secret access key, default region (eu-west-2) and default output format (yaml) when prompted
$ aws configure
AWS Access Key ID [None]: YOUR_AWS_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_AWS_SECRET_ACCESS_KEY
Default region name [None]: YOUR_AWS_REGION
Default output format [None]: yaml

# install kubeclt
$ curl -o kubectl.sha256 https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl.sha256
$ chmod +x ./kubectl
$ mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
$ kubectl version --short --client



2- try terraform

# let's create one single ec2 instance to see terraform in action
$ vim ec2.tf
# run terraform
$ terraform init
# to see what changes will be made
$ terraform plan
# to apply the planned changes
$ terraform apply
# after "terraform apply" command you will be asked to approve it. in order to avoid this you can use "terraform apply --auto-approve" command instead
# go to aws console and check ec2 instances, you should see a new instance named "single-instance". go back to terminal
$ terraform destroy
# you should now see instance state changed to "shutting-down"



3- deploy eks cluster

# make directory for cluster
$ mkdir cluster
$ cd cluster
# type content of cluster and variables files 
$ vim cluster.tf
# double check the file to make sure that you have the content of the file show that your aws region, vpc name, etc are correct

$ terraform init
$ terraform plan
$ terraform apply --auto-approve
# go to aws console and see that a new eks cluster (named my-eks-cluster) being formed and new instances starting. this may take few minutes. and in order to see the progress you may require to hit refresh button.



4- extra info

# if you want to check whether a configuration is syntactically valid and internally consistent, you may use
$ terraform validate
Success! The configuration is valid.
# terraform validate command validates the configuration files in a directory, referring only to the configuration and not accessing any remote services such as remote state, provider apis, etc

# terraform fmt command is used to rewrite Terraform configuration files to a canonical format and style. This command applies a subset of the terraform language style conventions, along with other minor adjustments for readability
$ terraform fmt



5- deploy wordpress

# make directory for infrastructure
$ mkdir infra
$ cd infra
# type content of infrastructure
$ vim infra.tf

# repeat the same set of terraform commands
$ terraform init
$ terraform plan
# i have received "unsupported attribute" error at this stage, unfortunately i do not have more time today. i will debug in near future and update once debugging completed.

$ terraform apply --auto-approve



6- wordpress gui

# 



7- clear all resources

# when finished with the task please go to same folders in reverse chronoligal order where you have used terraform apply command and use terraform destroy command to arease resources so that no extra cost occured
$ terraform destroy
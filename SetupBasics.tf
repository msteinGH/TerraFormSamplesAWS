
# do need to have credentials file ~/.aws/credentials set up via aws cli
# aws configure
# or edit manually:
#
# [default]
# aws_secret_access_key = XXX
# aws_access_key_id = YYY

provider "aws" {
	#region 		= "us-east-1"
    region 		= "${var.region}"
    shared_credentials_files = ["~/.aws/credentials"]
}

resource "aws_key_pair" "tf-generic-user-key" {
  key_name   = "tf-generic-user-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAp62kAHeRBzDaz8QpqdhIlvgPtnOVx2q1v2nGnYwYdVRlrWUIL8B3NyvCAwebu/T2+QXjTphfOXfd8z5gExxXnjuv/ECUILVjxuzwM3eC9C1YGCVekPObY8HqjvhNvpdz/sZpU3FgXi8mj9JN2+li+tgPZfejyhuzCXJrYICQ/x6iV2sxD7Rlwd4ALSQoaHO+/x72FimkfidtSawxRJszghY38+TVd3yi2SPBCd36MQtYPqHxj1GuLQmG+VrYXvdndTcf56mHCqsWIxSeJMtFEXjbP3eDjHku12hZqp+Vyt4bNh9kK6IV/dPPLCXeyew7gIz6jFk4UJBABsHc95+6BQ=="
}



# get GIT_TOKEN from script output (could also be used to read environment variables)
# expecting .bat file on PATH, executable, returning GIT_TOKEN in JSON format, e.g.
# #####################################################################
# @echo off
# echo  { "TF_GIT_TOKEN" : "ghp_XXXX_my_git_token" }
# #####################################################################
data "external" "env" {
  program = ["get_git_token.bat"]
}

# Print ALL values from externally read in variables/environment variables
#output "env" {
#  value = data.external.env.result
#}

# This prints value of "TF_GIT_TOKEN""
# output "git_token" {
#  value = data.external.env.result["TF_GIT_TOKEN"]
#}


# prepare template file by filling in value for git token
# replacing ${git_token} by values read in via external data above, i.e. script file output
data "template_file" "user_data" {
  template = "${file("user_data.sh")}"

  vars = {
    git_token = data.external.env.result["TF_GIT_TOKEN"]
  }
}

# debug templatefile
resource "null_resource" "example" {
  triggers = {
    json = "${data.template_file.user_data.rendered}"
  }
}


# S3 bucket samples
# WORKING with Basic Linux VM Oreilly example 
# or ONLY the FIRST one??-> SEEMINGLY YES!!!
# working again after first ACcoutn has timed out/ after 60 minutes??
# does NOT work with OReilly SSH, Apache, EBS, Snapshot,Security Groups, Custom AMI assignment/course, lacking permissions!!
# DOES work with ?? assignment 
# JUST DO use new name!!
# name has to be unique per region (AZ???)
# sometimes STILL permissions lacking even for manual creation???
# naming conventions at https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
# no underscores, jsut hyphens etc.

  module "sample_s3_bucket_with_uploaded_data" {
  source = "./Modules/S3"
  bucket_name = "my-tf-bucket-name-from-wrapper-call2"
}



# slowing down individual executions
# installing and starting helloworld tomcat on my-first-tf-instance-with-ssh-user-data-file at port 8080
# http://IP_ADDRESS:8080/test/index.jsp
  module "sample_ec2_instances_with_user_data" {
  source = "./Modules/EC2"
  subnet = aws_subnet.tf-generic-subnet.id
  security_groups = [aws_security_group.tf-allow-tcp-8080-8081.id,aws_security_group.tf-allow-ssh.id]
  key_name = "tf-generic-user-key"
}




# create VPC
resource "aws_vpc" "tf-generic-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf-generic-vpc"
  }
}

# create subnet
resource "aws_subnet" "tf-generic-subnet" {
  vpc_id            = aws_vpc.tf-generic-vpc.id

  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.availability_zone}"

  tags = {
    Name = "tf-generic-subnet"
  }
}

resource "aws_internet_gateway" "tf-my-internet-gateway" {
  vpc_id = aws_vpc.tf-generic-vpc.id
  tags = {
    Name = "tf-my-internet-gateway"
  }
}

resource "aws_route_table" "tf-my-route-table" {
  vpc_id = aws_vpc.tf-generic-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-my-internet-gateway.id
  }
  tags = {
    Name = "tf-my-route-table"
  }
}

resource "aws_route_table_association" "tf-my-route-table-association" {
 subnet_id = aws_subnet.tf-generic-subnet.id
 route_table_id = aws_route_table.tf-my-route-table.id
}

# create security group inbound via HTTP port 8080/8081
resource "aws_security_group" "tf-allow-tcp-8080-8081" {
  name        = "tf-allow-tcp-8080"
  description = "Allow ALL TCP on port 8080 inbound traffic"
  vpc_id      = aws_vpc.tf-generic-vpc.id

  ingress {
    description      = "HTTP from 8080"
    from_port        = 8080
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # outbound ALL protocols alllowed
  # make sure to be able to reach amazon and other repos for package installations 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tf-allow-tcp-8080"
  }
}



# create security group inbound via SSH from ALL, 
resource "aws_security_group" "tf-allow-ssh" {
  name        = "tf-allow-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.tf-generic-vpc.id

  ingress {
    description      = "SSH from ALL"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # outbound ALL protocols alllowed
  # make sure to be able to reach amazon and other repos for package installations 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "tf-allow-ssh"
  }
}



# set up EC2 instance
resource "aws_instance" "my-first-tf-instance" {

	ami = "ami-0b5eea76982371e91" 
	instance_type = "t2.micro"
	key_name = "tf-generic-user-key"
	# either subnet ID or network interface can be specified
	# interface cannot be specified together with pupblic IP
	# network_interface_id = aws_network_interface.tf_generic_network_interface.id
  subnet_id       = aws_subnet.tf-generic-subnet.id
	associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.tf-allow-ssh.id]
	
	tags = {
		Name = "my-first-tf-instance"
	}
}

# create ebs volume for extended storage
resource "aws_ebs_volume" "python-venv-ebs-volume" {
  availability_zone = "${var.availability_zone}"
  # size in GB
  size       = 100
  tags = {
    Name = "tf-python-venv-ebs-volume"
  }
}

# attach ebs volume to ec2 instance via ID
# needs to be mounted, maybe via user data script -> see AWS AI Setup
resource "aws_volume_attachment" "python-venv-ebs-volume-attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.python-venv-ebs-volume.id
  instance_id = aws_instance.my-first-tf-instance.id
}


# TODOS
# PARAMETERIZE   
# password/certificate reomval??
# public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEArt3ogLZPTxqC8AnyHmh+8fdDD0fqRLoW9p0G066ZTWSpDgOtf1gz9t2CUvzhzThtmSC7INMNV44NQho7AkuU6JuV7m/JC1qcqpqDM38k0+dFvrnKvVozOKZbTwfGeNNCaeC4GEdiCanyBIfK5JfaTCiHQQSS125HXo5nPpVhMQ3nfuYNFjtYDaPueclWKs3+O9F4ukGWZ+YAYDmUtbMBJJ+nonSyAcBqAYX+P+DWimNs56Dkf1LcSqoLZrs+AH71Z9EEdC1V7OXESoNEQObU4k71hhf0dA5f8XBF3JPI3esVYiHXqOWtgv3WzGTW2yyy7ZV+ir5Y66Xl8bGpkoXH7w=="


# CHECK DSF real thing
# - S3
# -- working from OReilly? -> YES
# -- use for logging? 
# -- access from 
# setup IAM user and roles and groups
# -- difference role group permission
# check autoscaling ECS, EKS
# https://www.reddit.com/r/aws/comments/mqbcg3/difference_between_eks_ecs_and_autoscaling_for_a/
# check EKS not from oreilly
# - requires IAM role
# check ECS not from OReilly
# check RDS not from oreilly
# - general usage
# - sample connect from tomcat
# -- /etc/tomcat /usr/sbin/tomcat /usr/share/java/tomcat (!!)
# -- sudo tomcat start
# -- enable web access!
# -- copy hello world page/memory?? via mediashare?? D/L unzip strange pop ups might not work
# https://www.mediafire.com/file/xq9r937nnsg9qqt/Memory.zip/file 
# 
# -- test locally first, same with DB connection
# access other services
# - Free RDS(?))
# -- NOPE not from OReilly
# -- set up Tomcat
# -- connect to PostgresSQL DB RDS via user_data.sh
# - DynamoDB not from OReilly
# -- NOSQL DB
# -- any good/worthwhile learning?
# - k8s not from OReilly
# -- Control PLane??
# - cloudwatch
# -- log into S3?? 
# -- free??
# checkout DDOS Protections
# checkout Route53 



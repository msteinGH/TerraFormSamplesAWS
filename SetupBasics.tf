
provider "aws" {
	#region 		= "us-east-1"
  region 		= "${var.region}"
	access_key 	= "AKIAU7KX6KHGZ2DXZDYH" 
	secret_key 	= "HKYXUtxniwI6Oh8c+2LLElp0A1fjCdR86jLy0Ej9"

}

# S3 bucket samples
# WORKING with Basic Linux VM Oreilly example 
# or ONLY the FIRST one??-> SEEMINGLY YES!!!
# does NOT work with OReilly SSH, Apache, EBS, Snapshot,Security Groups, Custom AMI assignment/course, lacking permissions!!
# DOES work with ?? assignment 
  module "sample_s3_bucket_with_uploaded_data" {
  source = "./Modules/S3"
  bucket_name = "my_new_bucket_name_from_wrapper_call"
}



# slowing down individual executions
  module "sample_ec2_instances_with_user_data" {
  source = "./Modules/EC2"
  subnet = aws_subnet.tf-generic-subnet.id
  security_group = aws_security_group.tf-allow-ssh.id
  key_name = "tf-generic-user-key"
}

resource "aws_key_pair" "tf-generic-user-key" {
  key_name   = "tf-generic-user-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEArt3ogLZPTxqC8AnyHmh+8fdDD0fqRLoW9p0G066ZTWSpDgOtf1gz9t2CUvzhzThtmSC7INMNV44NQho7AkuU6JuV7m/JC1qcqpqDM38k0+dFvrnKvVozOKZbTwfGeNNCaeC4GEdiCanyBIfK5JfaTCiHQQSS125HXo5nPpVhMQ3nfuYNFjtYDaPueclWKs3+O9F4ukGWZ+YAYDmUtbMBJJ+nonSyAcBqAYX+P+DWimNs56Dkf1LcSqoLZrs+AH71Z9EEdC1V7OXESoNEQObU4k71hhf0dA5f8XBF3JPI3esVYiHXqOWtgv3WzGTW2yyy7ZV+ir5Y66Xl8bGpkoXH7w=="
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
    #from_port        = 22
    #to_port          = 22
    #protocol         = "tcp"
    #cidr_blocks      = ["0.0.0.0/0"]
    
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
# WORKING!!
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
# have webapp D/L from GitHub and deployed into Tomcat  
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
# check which packages generally available via yum
# - Terraform???? makes sense?
# - Ansible??
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
# GIT / GITHub
# - Pull Requests
# - branches
# - different users
# - create Repo for downloading stuff
# -- with credentials? D/L user?


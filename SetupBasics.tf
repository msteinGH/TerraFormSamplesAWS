
provider "aws" {
	#region 		= "us-east-1"
  region 		= "${var.region}"
	access_key 	= "AKIAV33XBRPRM5PJVDFZ" 
	secret_key 	= "Tie8FTBbb1ps0YxSPILBTxXhaZyjZahIKUxH9d7/"

}

# slowing down individual executions
# module "sample_ec2_instances_with_user_data" {
#  source = "./SampleModule"
#  subnet = aws_subnet.tf-generic-subnet.id
#  security_group = aws_security_group.tf-allow-ssh.id
#  key_name = "tf-generic-user-key"
#}

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

# create an S3 bucket 
resource "aws_s3_bucket" "tf-my-first-aws-s3-bucketa" {
  bucket = "tf-my-first-aws-s3-bucketa"
  tags = {
    Name        = "${var.bucket_name}"
  }
}

resource "aws_s3_bucket_acl" "tf-my-first-aws_s3_bucket_acl" {
  bucket = aws_s3_bucket.tf-my-first-aws-s3-bucketa.id
  # acl    = "private"
   acl    = "public-read"
}

# Upload test file to S3 bucket
resource "aws_s3_object" "tf-generically-uploaded-file" {

  bucket = aws_s3_bucket.tf-my-first-aws-s3-bucketa.id
  key    = "S3BucketTestFile.txt"
  # acl    = "private"
   acl    = "public-read" 
   source = "./S3BucketTestFile.txt"

  etag = filemd5("S3BucketTestFile.txt")

}

# create empty folder in S3 bucket
resource "aws_s3_object" "tf-my-test-upload-folder-name" {
    provider = aws
    bucket = aws_s3_bucket.tf-my-first-aws-s3-bucketa.id
    acl    = "public-read" 
    key    = "tf-my-test-upload-folder-name/"
    # content_type seemingly irrelevant 
    # trailing "/" seems to be sole indicator to create a folder
    # content_type = "application/x-directory"
}

# create folder and upload files into it in one go
resource "aws_s3_object" "tf-my-test-upload-folder-name-incl-files" {
for_each = fileset("TestFilesForUpload/", "*")
bucket = aws_s3_bucket.tf-my-first-aws-s3-bucketa.id
key    = "tf-my-test-upload-folder-name-incl-files/${each.value}"
source = "TestFilesForUpload/${each.value}"

etag = filemd5("TestFilesForUpload/${each.value}")
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
# check which packages generally available via yum
# - Terraform???? makes sense?
# - Ansible??
# access other services
# - Free RDS(?))
# -- NOPE not from OReilly
# -- set up Tomcat
# -- connect to PostgresSQL DB RDS via user_data.sh
# - DynamoDB not from OReilly
# -- NOSSQL DB
# -- any good/worthwhile learning?
# - k8s not from OReilly
# -- Control PLane
# - cloudwatch
# -- log into S3?? 
# -- free??
# checkout DDOS Protections
# checkout Route53 
# GIT / GITHub
# - Pull Requests
# - branches
# - different users


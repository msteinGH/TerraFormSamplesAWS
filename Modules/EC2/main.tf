

# working fine, incl. SSH access, java installation via user_data
 resource "aws_instance" "my-first-tf-instance-with-ssh-user-data-file" {
	ami = "ami-0b5eea76982371e91" 
	instance_type = "t2.micro"
	key_name = "${var.key_name}"
  subnet_id = "${var.subnet}"
  security_groups = "${var.security_groups}"
	associate_public_ip_address = "true"
  user_data = "${file("user_data.sh")}"
  # can also use userdata from template file 
	# user_data = "${data.template_file.user_data.rendered}"
	tags = {
		Name = "my-first-tf-instance-with-ssh-user-data-file"
	}
}


resource "aws_ebs_volume" "tf-my-ebs-volume" {
  availability_zone = "us-east-1a"
  # size in GB
  size              = 13
  tags = {
    Name = "tf-my-ebs-volume"
  }
}

resource "aws_volume_attachment" "tf-my-ebs-volume-attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.tf-my-ebs-volume.id
  instance_id = aws_instance.my-first-tf-instance-user-data.id
}

# working fine, SSH access, java installation, mounting EBS volume via user_data
resource "aws_instance" "my-first-tf-instance-user-data" {

	ami = "ami-0b5eea76982371e91" 
	instance_type = "t2.micro"
  key_name = "${var.key_name}"
   subnet_id = "${var.subnet}"
   security_groups = "${var.security_groups}"
  #subnet_id = aws_subnet.tf-generic-subnet.id
	associate_public_ip_address = "true"
  # yum mmay fail if outbound http(s) calls are restricted via security group!!!
  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install -y java-1.8.0-openjdk.x86_64
            sudo mkfs -t xfs /dev/sdh
            sudo mkdir /mynewvolume
            sudo mount /dev/sdh /mynewvolume
            sudo yum install -y tomcat.noarch
            EOF
	tags = {
		Name = "my-first-tf-instance-user-data"
	}
}


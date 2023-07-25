 #!/bin/bash
 # installing docker, tomcat,Java
 sudo yum update -y

 #############Docker install and config
 sudo yum install -y docker.x86_64
 sudo service docker start
 ## alloow ec2-user to run docker commanbds
 sudo usermod -aG docker ec2-user
 sudo su - ec2-user
 ## D/L and start tomcat image
 docker pull tomcat
 ## map container port to EC2 server port
 ## make sure to have opened via secruity group
 docker run -p8081:8080 --name mytomcat -d tomcat
 ## calling IP_ADDRESS:8081/ from the internet should result in tomcat 404 error page
 
 
 ############## end of Docker

 ## python3 already pre-installed
 ## sudo yum install python3
 ## D/L and install pip as user/in home ./local/
 cd /tmp
 curl -O https://bootstrap.pypa.io/get-pip.py
 python3 get-pip.py --user

 sudo yum install -y java-1.8.0-openjdk.x86_64
 sudo yum install -y tomcat.noarch
 # D/L file from github into webapps dir
  cd /usr/share/tomcat/webapps
  sudo su 
  mkdir test
  chgrp tomcat test
  cd test
  curl https://raw.githubusercontent.com/msteinGH/TerraFormSamplesAWS/main/SampleData/StaticHtml/index.jsp >> index.jsp 
  chgrp tomcat index.jsp 
  /usr/sbin/tomcat start
  exit
  

 # tomcat infos
 # install dirs 
 # /etc/tomcat 
 # /usr/sbin/tomcat 
 # /usr/share/java/tomcat
 # running on port 8080
 # test via curl -v localhost:8080/test/index.jsp

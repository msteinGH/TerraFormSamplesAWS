 #!/bin/bash
 # installing tomcat and Java
 sudo yum update -y
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

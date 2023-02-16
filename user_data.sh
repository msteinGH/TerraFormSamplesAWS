 #!/bin/bash
 # installing tomcat and Java
 sudo yum update -y
 sudo yum install -y java-1.8.0-openjdk.x86_64
 # tomcat install dirs 
 # /etc/tomcat 
 # /usr/sbin/tomcat 
 # /usr/share/java/tomcat
 sudo yum install -y tomcat.noarch
 # D/L file from github into webapps dir
 # cd /usr/share/tomcat/webapps
 # sudo su 
 # curl https://raw.githubusercontent.com/msteinGH/TerraFormSamplesAWS/main/SampleData/StaticHtml/index.jsp >> index.jsp 
 # chgrp tomcat index.jsp 
 # exit
  
FROM tomcat
# execute commands within the container via RUN
RUN mkdir /usr/local/tomcat/webapps/test

# copy files from the HOST to the image
# can cause some problems when copying from other folders within the context of wsl mountpoints
# so better copy from current directory/subdirectory 
COPY ./index.jsp /usr/local/tomcat/webapps/test

# command to be run after every container start
CMD ["catalina.sh", "run"]
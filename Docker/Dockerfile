FROM tomcat
RUN mkdir /usr/local/tomcat/webapps/test
COPY ./index.jsp /usr/local/tomcat/webapps/test
CMD ["catalina.sh", "run"]
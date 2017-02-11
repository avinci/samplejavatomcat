FROM tomcat:8.0.20-jre8

RUN rm -rf /usr/local/tomcat/webapps/HelloWorld.war
COPY HelloWorld.war /usr/local/tomcat/webapps/HelloWorld.war

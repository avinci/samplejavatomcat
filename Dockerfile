FROM tomcat:8.0.20-jre8

RUN rm -rf /usr/local/tomcat/webapps/*

COPY sample.war /usr/local/tomcat/webapps/sample.war

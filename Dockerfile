FROM tomcat:8.0.20-jre8

RUN rm -rf /usr/local/tomcat/webapps/*

COPY /build/IN/demo-doc-repo/gitRepo/sample.war /usr/local/tomcat/webapps/sample.war

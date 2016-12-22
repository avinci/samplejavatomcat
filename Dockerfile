FROM tomcat:8.0.20-jre8

RUN rm -rf /usr/local/tomcat/webapps/*

COPY $SHIPPABLE_BUILD_DIR/sample.war /usr/local/tomcat/webapps/sample.war

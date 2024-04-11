FROM nriet/tomcat:8.5-jdk11-thredds

MAINTAINER axiu

USER root

# tds envs
ENV TDS_CONTENT_ROOT_PATH /usr/local/tomcat/content
ENV THREDDS_XMX_SIZE 4G
ENV THREDDS_XMS_SIZE 4G
ENV THREDDS_WAR_URL http://data.nriet.xyz/thredds-5.5-SNAPSHOT.war

COPY files/threddsConfig.xml ${CATALINA_HOME}/content/thredds/threddsConfig.xml
COPY files/tomcat-users.xml ${CATALINA_HOME}/conf/tomcat-users.xml
COPY files/setenv.sh ${CATALINA_HOME}/bin/setenv.sh
COPY files/javaopts.sh ${CATALINA_HOME}/bin/javaopts.sh

# Install necessary packages
RUN curl -fSL "${THREDDS_WAR_URL}" -o thredds.war && \
    unzip thredds.war -d ${CATALINA_HOME}/webapps/thredds/ && \
    rm -f thredds.war && \
    mkdir -p ${CATALINA_HOME}/content/thredds && \
    chmod 755 ${CATALINA_HOME}/bin/*.sh && \
    mkdir -p ${CATALINA_HOME}/javaUtilPrefs/.systemPrefs

EXPOSE 8080 8443

WORKDIR ${CATALINA_HOME}

# Inherited from parent container
ENTRYPOINT ["/entrypoint.sh"]

# Start container
CMD ["catalina.sh", "run"]

HEALTHCHECK --interval=10s --timeout=3s \
	CMD curl --fail 'http://localhost:8080/thredds/catalog.html' || exit 1

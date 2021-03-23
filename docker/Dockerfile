FROM tomcat:8

ENV GN_FILE geonetwork.war
ENV DATA_DIR=$CATALINA_HOME/webapps/geonetwork/WEB-INF/data
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -server -Xms512m -Xmx2024m -XX:NewSize=512m -XX:MaxNewSize=1024m -XX:+UseConcMarkSweepGC"
ENV KB_URL=http://kibana:5601

#Environment variables
ENV GN_VERSION 3.10.5

WORKDIR $CATALINA_HOME/webapps

COPY ./$GN_FILE $CATALINA_HOME/webapps/$GN_FILE

RUN mkdir -p geonetwork && \
     unzip -e $GN_FILE -d geonetwork && \
     rm $GN_FILE


#Set geonetwork data dir
COPY ./docker-entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["catalina.sh", "run"]

HEALTHCHECK --interval=1m --timeout=10s --retries=5 \
    CMD curl -i -H \"Accept: application/json\" -f http://localhost:8080/geonetwork/srv/api/0.1/site || exit 1


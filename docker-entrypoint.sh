#!/bin/bash
set -e

if [ "$1" = 'catalina.sh' ]; then

	mkdir -p "$DATA_DIR"

	#Set geonetwork data dir
	export CATALINA_OPTS="$CATALINA_OPTS -Dgeonetwork.dir=$DATA_DIR"
	#export CATALINA_HOME="/usr/local/tomcat"

	 # Reconfigure Elasticsearch & Kibana if necessary
    if [ "$ES_HOST" != "localhost" ]; then
       sed -i "s#http://localhost:9200#${ES_PROTOCOL}://${ES_HOST}:${ES_PORT}#g" /usr/local/tomcat/webapps/geonetwork/WEB-INF/web.xml ;
      sed -i "s#es.host=localhost#es.host=${ES_HOST}#" /usr/local/tomcat/webapps/geonetwork/WEB-INF/config.properties ;
   fi;

   if [ "$ES_PROTOCOL" != "http" ] ; then
      sed -i "s#es.protocol=http#es.protocol=${ES_PROTOCOL}#" /usr/local/tomcat/webapps/geonetwork/WEB-INF/config.properties ;
    fi

    if [ "$ES_PORT" != "9200" ] ; then
      sed -i "s#es.port=9200#es.port=${ES_PORT}#" /usr/local/tomcat/webapps/geonetwork/WEB-INF/config.properties ;
    fi
    if [ "$ES_USERNAME" != "" ] ; then
      sed -i "s#es.username=#es.username=${ES_USERNAME}#" /usr/local/tomcat/webapps/geonetwork/WEB-INF/config.properties ;
    fi
    if [ "$ES_PASSWORD" != "" ] ; then
      sed -i "s#es.password=#es.password=${ES_PASSWORD}#" /usr/local/tomcat/webapps/geonetwork/WEB-INF/config.properties ;
    fi

    if [ "$KB_URL" != "http://localhost:5601" ]; then
      sed -i "s#kb.url=http://localhost:5601#kb.url=${KB_URL}#" /usr/local/tomcat/webapps/geonetwork/WEB-INF/config.properties ;
      sed -i "s#http://localhost:5601#${KB_URL}#g" /usr/local/tomcat/webapps/geonetwork/WEB-INF/web.xml ;
    fi
fi

exec "$@"

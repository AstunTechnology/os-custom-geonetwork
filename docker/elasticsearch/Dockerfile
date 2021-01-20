FROM docker.elastic.co/elasticsearch/elasticsearch:7.6.2

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY setup.sh /setup.sh
COPY wait-for-it.sh /wait-for-it.sh


COPY features.json /features.json
COPY records.json /records.json
COPY searchlogs.json /searchlogs.json

USER root
RUN chmod +x /docker-entrypoint.sh /wait-for-it.sh /setup.sh
RUN chown -R elasticsearch:elasticsearch /docker-entrypoint.sh /wait-for-it.sh /setup.sh

USER elasticsearch
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]

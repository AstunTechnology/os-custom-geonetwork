FROM docker.elastic.co/elasticsearch/elasticsearch:7.6.2

COPY docker-entrypoint.sh setup.sh wait-for-it.sh /

COPY features.json records.json searchlogs.json /

USER root
RUN chmod +x /docker-entrypoint.sh /wait-for-it.sh /setup.sh
RUN chown -R elasticsearch:elasticsearch /docker-entrypoint.sh /wait-for-it.sh /setup.sh

USER elasticsearch
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]
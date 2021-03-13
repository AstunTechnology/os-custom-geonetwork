#!/bin/bash
cd /home/ec2-user && \
# schemas
curl -fSL https://github.com/AstunTechnology/iso19139.gemini23/archive/3.10.x.zip -o gemini23.zip && \
mkdir -p schemas && \
unzip -o gemini23.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/iso19139.nonspatial/archive/master.zip -o nonspatial.zip && \
unzip -o nonspatial.zip -d schemas && \
curl -fSL https://github.com/metadata101/dcat2/archive/master.zip -o dcat.zip && \
unzip -o dcat.zip -d schemas && \
# directories
mkdir -p pgdata esdata nginx kibana elasticsearch && \
cp -rf /home/ec2-user/docker-geonetwork/nginx/* /home/ec2-user/nginx && \
cp -rf /home/ec2-user/docker-geonetwork/kibana/* /home/ec2-user/kibana  && \
#cp -rf /home/ec2-user/os-custom-geonetwork/geonetwork/* /home/ec2-user/geonetwork  && \
cp -rf /home/ec2-user/docker-geonetwork/elasticsearch/* /home/ec2-user/elasticsearch  && \
#cp -rf /home/ec2-user/os-custom-geonetwork/thesauri/* /home/ec2-user/geonetwork/thesauri && \
# # postgresql audit script (in progress)
# curl -fSL https://github.com/AstunTechnology/audit-trigger/archive/master.zip -o audit-trigger.zip && \
# mkdir -p audit-trigger && \
# unzip -o audit-trigger.zip -d audit-trigger && \
# cp -rf /home/ec2-user/audit-trigger/audit-trigger-master/audit.sql /home/ec2-user/postgresql && \
# finally make sure we can access all the directories
chown -Rf ec2-user:ec2-user pgdata esdata nginx kibana elasticsearch

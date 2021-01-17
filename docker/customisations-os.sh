#!/bin/bash
cd /home/ec2-user && \
curl -fSL https://github.com/AstunTechnology/iso19139.gemini23/archive/3.10.x.zip -o gemini23.zip && \
mkdir -p schemas && \
unzip -o gemini23.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/iso19139.gemini22_GN3/archive/3.8.x.zip -o gemini22.zip && \
unzip -o gemini22.zip -d schemas && \
mkdir -p pgdata esdata geonetwork/thesauri nginx kibana elasticsearch && \
cp -rf /home/ec2-user/os-custom-geonetwork/nginx/* /home/ec2-user/nginx && \
cp -rf /home/ec2-user/os-custom-geonetwork/kibana/* /home/ec2-user/kibana  && \
cp -rf /home/ec2-user/os-custom-geonetwork/elasticsearch/* /home/ec2-user/elasticsearch  && \
cp -rf /home/ec2-user/os-custom-geonetwork/thesauri/* /home/ec2-user/geonetwork/thesauri && \
chown -Rf ec2-user:ec2-user pgdata esdata geonetwork nginx kibana elasticsearch

#!/bin/bash
cd /home/ec2-user && \
curl -fSL https://github.com/AstunTechnology/iso19139.gemini23/archive/3.10.x.zip -o gemini23.zip && \
mkdir schemas && \
unzip gemini23.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/iso19139.gemini22_GN3/archive/3.8.x.zip -o gemini22.zip && \
unzip gemini22.zip -d schemas && \
#curl -fSL https://raw.githubusercontent.com/geonetwork/docker-geonetwork/master/3.10.5/postgres/jdbc.properties -o jdbc.properties && \
mkdir pgdata && \
mkdir esdata && \
mkdir -p geonetwork/thesauri && \
mkdir nginx && \
chown ec2-user:ec2-user pgdata esdata geonetwork nginx && \
cp /home/ec2-user/os-custom-geonetwork/nginx/default /home/ec2-user/nginx && \
cp -r /home/ec2-user/os-custom-geonetwork/thesauri/*.rdf /home/ec2-user/geonetwork/thesauri

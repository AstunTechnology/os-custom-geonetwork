#!/bin/bash
cd /home/ec2-user && \
curl -fSL https://github.com/AstunTechnology/iso19139.gemini23/archive/3.10.x.zip -o gemini23.zip && \
mkdir -p schemas && \
unzip -o gemini23.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/iso19139.gemini22_GN3/archive/3.8.x.zip -o gemini22.zip && \
unzip -o gemini22.zip -d schemas && \
#curl -fSL https://raw.githubusercontent.com/geonetwork/docker-geonetwork/master/3.10.5/postgres/jdbc.properties -o jdbc.properties && \
mkdir -p pgdata && \
mkdir -p esdata && \
mkdir -p geonetwork/thesauri && \
mkdir -p nginx && \
chown -Rf ec2-user:ec2-user pgdata esdata geonetwork nginx && \
cp -rf /home/ec2-user/os-custom-geonetwork/nginx/* /home/ec2-user/nginx && \
cp -rf /home/ec2-user/os-custom-geonetwork/thesauri/*.rdf /home/ec2-user/geonetwork/thesauri

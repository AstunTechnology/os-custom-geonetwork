#!/bin/bash
yum -y install unzip
cd /home/ec2-user && \
curl -fSL https://github.com/AstunTechnology/iso19139.gemini23/archive/3.10.x.zip -o gemini.zip && \
mkdir schemas && \
unzip gemini.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/iso19139.eamp/archive/3.10.x.zip -o eamp.zip && \
unzip eamp.zip -d schemas && \
curl -fSL https://raw.githubusercontent.com/geonetwork/docker-geonetwork/master/3.10.5/postgres/jdbc.properties -o jdbc.properties && \
echo -e "\nECS_ENGINE_AUTH_TYPE=dockercfg" >> /etc/ecs/ecs.config
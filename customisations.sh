#!/bin/bash

# This file is to allow you to make customisations to the docker config on ECS without you needing to 
# redeploy the entire EC2 instance. The repository is downloaded ad this script run as part of the server 
# initialisation but you can ssh onto the server and git pull changes, then run this as required

cd /home/ec2-user && \
# schemas
curl -fSL https://github.com/AstunTechnology/iso19139.gemini23/archive/3.10.x.zip -o gemini23.zip && \
mkdir -p schemas && \
unzip -o gemini23.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/iso19139.nonspatial/archive/main.zip -o nonspatial.zip && \
unzip -o nonspatial.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/dcat2/archive/3.10.x.zip -o dcat.zip && \
unzip -o dcat.zip -d schemas
# directories
mkdir -p pgdata esdata nginx kibana elasticsearch geonetwork-customisations geonetwork tomcat && \
cp -rf /home/ec2-user/docker-geonetwork/nginx/* /home/ec2-user/nginx && \
cp -rf /home/ec2-user/docker-geonetwork/kibana/* /home/ec2-user/kibana  && \
cp -rf /home/ec2-user/docker-geonetwork/odi-customisations/geonetwork/* /home/ec2-user/geonetwork-customisations  && \
cp -rf /home/ec2-user/docker-geonetwork/elasticsearch/* /home/ec2-user/elasticsearch  && \
cp -rf /home/ec2-user/docker-geonetwork/tomcat/* /home/ec2-user/tomcat  && \
cp -rf /home/ec2-user/docker-geonetwork/geonetwork/* /home/ec2-user/geonetwork  && \

chown -Rf ec2-user:ec2-user pgdata esdata nginx kibana elasticsearch schemas geonetwork-customisations geonetwork tomcat

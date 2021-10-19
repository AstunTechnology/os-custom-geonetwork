#!/bin/bash

# This file is to allow you to make customisations to the docker config on ECS without you needing to 
# redeploy the entire EC2 instance. The repository is downloaded ad this script run as part of the server 
# initialisation but you can ssh onto the server and git pull changes, then run this as required

cd /home/ec2-user && \
# schemas
curl -fSL https://github.com/AstunTechnology/iso19139.gemini23/archive/3.12.x.zip -o gemini23.zip && \
mkdir -p schemas && \
unzip -o gemini23.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/iso19139.gemini22_GN3/archive/3.12.x.zip -o gemini22.zip && \
mkdir -p schemas && \
unzip -o gemini22.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/iso19139.eamp/archive/3.12.x.zip -o eamp.zip && \
mkdir -p schemas && \
unzip -o eamp.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/iso19139.nonspatial/archive/3.12.x.zip -o nonspatial.zip && \
unzip -o nonspatial.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/GDPR/archive/3.12.x.zip -o gdpr.zip && \
unzip -o gdpr.zip -d schemas
# curl -fSL https://github.com/AstunTechnology/dcat2/archive/3.10.x.zip -o dcat.zip && \
# unzip -o dcat.zip -d schemas
# curl -fSL https://github.com/AstunTechnology/iso19139.osmp/archive/refs/heads/3.10.x.zip -o osmp.zip && \
# unzip -o osmp.zip -d schemas

# skins
curl -fSL https://github.com/AstunTechnology/geonetwork-ea-skin/archive/3.12.x.zip -o ea.zip && \
mkdir -p skins && \
unzip -o ea.zip -d skins

# directories
mkdir -p pgdata esdata nginx kibana elasticsearch geonetwork-customisations geonetwork tomcat clamav zeppelin shiro-geonetwork jdk && \
cp -rf /home/ec2-user/docker-geonetwork/nginx/* /home/ec2-user/nginx && \
cp -rf /home/ec2-user/docker-geonetwork/kibana/* /home/ec2-user/kibana  && \
cp -rf /home/ec2-user/docker-geonetwork/elasticsearch/* /home/ec2-user/elasticsearch  && \
cp -rf /home/ec2-user/docker-geonetwork/tomcat/* /home/ec2-user/tomcat  && \
cp -rf /home/ec2-user/docker-geonetwork/geonetwork/* /home/ec2-user/geonetwork  && \
cp -rf /home/ec2-user/docker-geonetwork/jdk/* /home/ec2-user/jdk  && \
cp -rf /home/ec2-user/docker-geonetwork/clamav/* /home/ec2-user/clamav  && \
cp -rf /home/ec2-user/docker-geonetwork/zeppelin/* /home/ec2-user/zeppelin  && \
cp -rf /home/ec2-user/docker-geonetwork/shiro-geonetwork/* /home/ec2-user/shiro-geonetwork  && \
cp -rf /home/ec2-user/docker-geonetwork/shiro-geonetwork/conf/shiro.ini.geonetworkexample /home/ec2-user/shiro-geonetwork/conf/shiro.ini  && \

chown -Rf ec2-user:ec2-user pgdata esdata nginx kibana elasticsearch schemas geonetwork-customisations geonetwork tomcat clamav zeppelin shiro-geonetwork jdk skins

sed -i "s/dataSource.serverName = localhost/dataSource.serverName = $shirohost/" /home/ec2-user/shiro-geonetwork/conf/shiro.ini
sed -i "s/dataSource.user = user/dataSource.user = $shirouser/" /home/ec2-user/shiro-geonetwork/conf/shiro.ini
sed -i "s/dataSource.password = password/dataSource.password = $shiropassword/" /home/ec2-user/shiro-geonetwork/conf/shiro.ini
sed -i "s/dataSource.databaseName = geonetwork/dataSource.databaseName = $shirodbname/" /home/ec2-user/shiro-geonetwork/conf/shiro.ini

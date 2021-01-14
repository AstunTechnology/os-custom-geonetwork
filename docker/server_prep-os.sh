#!/bin/bash
yum -y update
yum -y install unzip git
cd /home/ec2-user && \
git clone https://github.com/AstunTechnology/os-custom-geonetwork.git && \
chmod +x os-custom-geonetwork/docker/customisations-os.sh && \
./os-custom-geonetwork/docker/customisations-os.sh
# curl -fSL https://github.com/AstunTechnology/iso19139.gemini23/archive/3.10.x.zip -o gemini23.zip && \
# mkdir schemas && \
# unzip gemini23.zip -d schemas && \
# curl -fSL https://github.com/AstunTechnology/iso19139.gemini22_GN3/archive/3.8.x.zip -o gemini22.zip && \
# unzip gemini22.zip -d schemas && \
# #curl -fSL https://raw.githubusercontent.com/geonetwork/docker-geonetwork/master/3.10.5/postgres/jdbc.properties -o jdbc.properties && \
# mkdir pgdata && \
# mkdir esdata && \
# mkdir geonetwork && \
# mkdir nginx
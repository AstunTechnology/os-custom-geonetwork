#!/bin/bash
yum -y update
yum -y install unzip git
cd /home/ec2-user && \
git clone https://github.com/AstunTechnology/os-custom-geonetwork.git && \
chmod +x os-custom-geonetwork/docker/customisations-os.sh && \
./os-custom-geonetwork/docker/customisations-os.sh

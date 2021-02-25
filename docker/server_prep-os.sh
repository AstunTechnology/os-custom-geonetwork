#!/bin/bash
yum -y update
yum -y install unzip git
cd /home/ec2-user
git clone https://github.com/AstunTechnology/os-custom-geonetwork.git
chmod +x os-custom-geonetwork/docker/customisations-os.sh
./os-custom-geonetwork/docker/customisations-os.sh
sudo mv ./os-custom-geonetwork/docker/docker-security/daemon.json /etc/docker/daemon.json
sudo chown root:root /etc/docker/daemon.json
sudo service docker restart


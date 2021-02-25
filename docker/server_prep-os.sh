#!/bin/bash
yum -y update
yum -y install unzip git
cd /home/ec2-user
git clone https://github.com/AstunTechnology/os-custom-geonetwork.git
chmod +x os-custom-geonetwork/docker/customisations-os.sh
./os-custom-geonetwork/docker/customisations-os.sh


# docker-bench-security issues 1.5-1.13
echo "-w /usr/bin/docker -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /var/lib/docker -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/docker -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /lib/systemd/system/docker.service -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /lib/systemd/system/docker.socket -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/default/docker -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/docker/daemon.json -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /usr/bin/docker-containerd -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /usr/bin/docker-runc -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
#echo "-w docker.socket -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
#echo "-w docker.service -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
sudo service auditd restart

# docker-bench-security issues 2.1-2.15 and 4.5
echo "DOCKER_CONTENT_TRUST=1" | sudo tee -a /etc/environment
sudo mv ./os-custom-geonetwork/docker/docker-security/daemon.json /etc/docker/daemon.json
sudo chown root:root /etc/docker/daemon.json
sudo service docker restart




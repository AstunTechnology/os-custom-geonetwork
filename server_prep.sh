#!/bin/bash

# This file is for customisations to the EC2 instance, not to the docker containers.
# It's for security config changes mainly.
# It can be run as one of the --extra--user-data parameters for the ecs-cli cluster up script
# In that case it should be run second, after bitbucket.sh

# If run manually from the EC2 instance it should be run as root

yum update -y
amazon-linux-extras install docker -y
yum install git unzip telnet -y
service docker start
usermod -a -G docker astun
systemctl enable docker
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose


# docker-bench-security issues 1.5-1.13
echo "-w /usr/bin/docker -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /var/lib/docker -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/docker -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /usr/lib/systemd/system/docker.service -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /usr/lib/systemd/system/docker.socket -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/default/docker -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/docker/daemon.json -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /usr/bin/docker-containerd -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /usr/bin/docker-runc -p wa" | sudo tee -a /etc/audit/rules.d/audit.rules

# increase vm.max_map_count on host for elasticsearch container
# using sysctl.d/*.conf as per AWS preferences
echo "vm.max_map_count=262144" >> /etc/sysctl.d/77-docker.conf

service auditd restart
cat > /etc/docker/daemon.json << EOL
        {
			"icc": false,
			"live-restore": true,
 			"log-driver": "syslog",
			"log-opts": {
    			"syslog-address": "udp://1.2.3.4:1111"
  			},
			"storage-driver": "overlay2",
			"userland-proxy": false,
			"no-new-privileges": true,
			#"userns-remap": "default"

		}
EOL
chown root:root /etc/docker/daemon.json
service docker restart





#!/bin/bash


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
			"no-new-privileges": true
		}
EOL
chown root:root /etc/docker/daemon.json
service docker restart




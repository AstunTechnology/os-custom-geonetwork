#!/bin/bash
yum -y update
yum -y install unzip git
cd /home/ec2-user && \
curl -fSL https://github.com/AstunTechnology/iso19139.gemini23/archive/3.10.x.zip -o gemini23.zip && \
mkdir -p schemas && \
unzip -o gemini23.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/iso19139.nonspatial/archive/main.zip -o nonspatial.zip && \
unzip -o nonspatial.zip -d schemas && \
curl -fSL https://github.com/AstunTechnology/dcat2/archive/master.zip -o dcat.zip && \
unzip -o dcat.zip -d schemas
mkdir nginx
cat > nginx/default.conf << EOL
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }


    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /var/www/html;
    }
	 	
	location /geonetwork {
	 	proxy_set_header Host \$$host;
	 	proxy_set_header X-Real-IP \$remote_addr;
	 	proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
	 	#proxy_pass      http://geonetwork:8080;
	 	proxy_pass      http://localhost:8080;
	 	client_max_body_size 30M;
	 	proxy_send_timeout          36000;
	 	proxy_read_timeout         36000;
	 	send_timeout                36000;
	 	proxy_intercept_errors on;
	 	error_page 404 /404.html;
	 	if (\$http_x_forwarded_proto = "http") {
	 				rewrite ^/(.*)\$ https://\$host\$request_uri;
	 	  		}
	}
}
EOL
cat > nginx/robots.txt << EOL
User-agent: *
Disallow:/
EOL
chown -Rf ec2-user:ec2-user nginx
mkdir kibana
cat > kibana/kibana.yml << EOL
server.basePath: "/geonetwork/dashboards"
server.rewriteBasePath: false
kibana.index: ".dashboards"
server.name: kibana
server.host: "0"
elasticsearch.hosts: [ "http://localhost:9200" ]
xpack.monitoring.ui.container.elasticsearch.enabled: true
EOL
chown -Rf ec2-user:ec2-user kibana schemas nginx
echo "-w /usr/bin/docker -p wa" | tee -a /etc/audit/rules.d/audit.rules
echo "-w /var/lib/docker -p wa" | tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/docker -p wa" | tee -a /etc/audit/rules.d/audit.rules
echo "-w /lib/systemd/system/docker.service -p wa" | tee -a /etc/audit/rules.d/audit.rules
echo "-w /lib/systemd/system/docker.socket -p wa" | tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/default/docker -p wa" | tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/docker/daemon.json -p wa" | tee -a /etc/audit/rules.d/audit.rules
echo "-w /usr/bin/docker-containerd -p wa" | tee -a /etc/audit/rules.d/audit.rules
echo "-w /usr/bin/docker-runc -p wa" | tee -a /etc/audit/rules.d/audit.rules
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




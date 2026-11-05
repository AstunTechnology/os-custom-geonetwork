location /zeppelin/ {

	 		#forward zeppelin requests to port 8083
	         proxy_pass http://zeppelin:8083/;
	         proxy_set_header X-Real-IP $remote_addr;
	         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	         proxy_set_header Host $http_host;
	         proxy_set_header X-NginX-Proxy true;
	         limit_req zone=ip burst=100 delay=75;
	         client_max_body_size 30M;
	         proxy_send_timeout         60000;
	         proxy_read_timeout         60000;
	         send_timeout               60000;
	}

	location /zeppelin/ws {
	         proxy_pass http://zeppelin:8083/ws;
	         proxy_http_version 1.1;
	         proxy_set_header Upgrade $http_upgrade;
	         proxy_set_header Connection "Upgrade";
	}
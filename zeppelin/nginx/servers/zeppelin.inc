server  {

	listen 8443 ssl http2;
	listen [::]:8443 ssl http2; 

	#ssl on;
	ssl_certificate /etc/nginx/certs/fullchain.pem;
	ssl_certificate_key /etc/nginx/certs/privkey.pem;

	server_name _;

	#valid_referers none server_names;
	#if ($invalid_referer) {
	#    return 403;
	#}

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

	ssl_session_cache shared:SSL:10m;
	ssl_session_timeout 5m;
	ssl_protocols TLSv1.1 TLSv1.2;
	ssl_prefer_server_ciphers on;
	ssl_dhparam /etc/nginx/ssl/dhparam.pem;
	ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256;

	port_in_redirect on;
	server_name_in_redirect off;
	
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

}
	 
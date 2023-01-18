server	{
 	listen 82;
 	# DEFRA EXT HARVESTING
 	#allow 172.31.15.45/32;
 	# RANGE FOR DEFRA SERVERS INTERNAL IPS
 	#allow 10.11.21.0/24;
 	# deny requests from all other IPs
 	#deny all;
 	
 	location /geonetwork/ {
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass      http://geonetwork:8080;
		proxy_intercept_errors on;
		#limit_req zone=public burst=60;
		#limit_conn default 5;
		 error_page 500 =404 @null;
		error_page 301 =404 @null;
		proxy_read_timeout 1440s;
 	}


}
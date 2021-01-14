#redirect for CSW endpoint

location /catalogue/metadata/v1/csw {
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass      http://localhost:8080/geonetwork/srv/eng/csw;
		proxy_intercept_errors on;
		error_page 500 =404 @null;
		error_page 301 =404 @null;
		proxy_read_timeout 1800;
		proxy_connect_timeout 1800;
        	proxy_send_timeout    1800;
		}
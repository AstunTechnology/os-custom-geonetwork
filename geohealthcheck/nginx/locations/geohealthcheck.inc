location  /geohealthcheck {
        #resolver 127.0.0.11 ipv6=off;
        proxy_pass http://geohealthcheck/geohealthcheck;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        }
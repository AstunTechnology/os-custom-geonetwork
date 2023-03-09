location  /geohealthcheck {

# forward geohealthcheck requests to port 8082

        proxy_pass http://geohealthcheck:8082$request_uri;
        #proxy_pass      http://geohealthcheck:8082/geohealthcheck;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
}
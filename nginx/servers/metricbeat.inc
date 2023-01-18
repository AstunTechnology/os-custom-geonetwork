server {
  listen 999;
  location /server-status {
    stub_status on;
    access_log off;
  }
  }
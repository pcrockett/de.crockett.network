#!/usr/bin/env bash

cat << EOF

#user html;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;

events {
    worker_connections  1024;
}

http {
    types_hash_bucket_size 128; # The following mime.types has so many entries, we need to include our hash bucket size. https://nginx.org/en/docs/hash.html
    include mime.types;
    default_type application/octet-stream;

    #log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    #                  '\$status \$body_bytes_sent "\$http_referer" '
    #                  '"\$http_user_agent" "\$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen 80 default_server;
        server_name ${DOMAIN_PRIMARY};

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }

    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2; # Listen on IPv6
        server_name ${DOMAIN_PRIMARY};

        ssl_certificate /etc/letsencrypt/live/${DOMAIN_PRIMARY}/fullchain.pem; # managed by Certbot
        ssl_certificate_key /etc/letsencrypt/live/${DOMAIN_PRIMARY}/privkey.pem; # managed by Certbot
        include /etc/letsencrypt/options-ssl-nginx.conf;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }
    }

}

EOF
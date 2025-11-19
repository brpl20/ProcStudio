user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    keepalive_timeout 80;
    gzip on;

${CLOUDFLARE_REAL_IP}

    upstream backend {
        least_conn;
${UPSTREAM_SERVERS}
        keepalive 16;
    }

    server {
        listen 80;
        server_name ${API_HOST};
        sendfile off;

${CLOUDFLARE_IPS_FIREWALL}
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_buffering off;
        }
    }

    server {
        listen 80 default_server;
        server_name ${FRONT_HOST};
        sendfile on;
        client_max_body_size ${PUBLIC_MAX_UPLOAD_MB}M;
        client_body_timeout 10m;

        location / {
            proxy_pass http://${NGINX_LOCALHOST}:${PORT};
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}

#!/bin/bash

mkdir -p /etc/nginx/certs

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/server.key \
    -out /etc/nginx/certs/server.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=czhu/CN=czhu.42.fr"
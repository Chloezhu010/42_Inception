# base OS
FROM debian:bookworm

# install ngnix
# refresh package index
RUN apt-get update \
    # install nginx and openssl
    && apt-get install -y nginx openssl \
    # cleanup apt caches to reduce image size
    && rm -rf /var/lib/apt/lists/*

# create certs for https
COPY tools/generate_certs.sh /generate_certs.sh
RUN chmod +x /generate_certs.sh && /generate_certs.sh

# copy the defaut.conf into the container
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# listen on port 80 for now
EXPOSE 443

# run it
CMD ["nginx", "-g", "daemon off;"]
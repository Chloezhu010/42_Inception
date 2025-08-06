# base OS
FROM debian:bookworm

# install ngnix
# refresh package index
RUN apt-get update \
    # install nginx
    && apt-get install -y nginx \
    # cleanup apt caches to reduce image size
    && rm -rf /var/lib/apt/lists/*

# copy the defaut.conf into the container
COPY conf/default.conf /etc/ngnix/conf.d/default.conf

# listen on port 80 for now
EXPOSE 80

# run it
CMD ["nginx", "-g", "daemon off;"]
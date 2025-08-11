# base OS
FROM debian:bookworm

# install php and extensions
# refresh package index
RUN apt-get update \
    # install php and extensions
    && apt-get install -y php php-mysqli php-fpm php-cli php-redis wget curl tar mariadb-client \
    # cleanup apt caches to reduce image size
    && rm -rf /var/lib/apt/lists/*

# config php-fpm to listen on port 9000 from all interfaces
RUN sed -i 's/listen =.*/listen = 9000/g' /etc/php/8.2/fpm/pool.d/www.conf

# create wordpress dir
RUN mkdir -p /var/www/wordpress

# create startup script
COPY tools/init_wordpress.sh /init_wordpress.sh
RUN chmod +x /init_wordpress.sh

# listen on port 9000 (to talk to nginx)
EXPOSE 9000

# run the php-fpm as foreground mode
ENTRYPOINT [ "/init_wordpress.sh" ]
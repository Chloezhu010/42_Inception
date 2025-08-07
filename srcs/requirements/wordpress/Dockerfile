# base OS
FROM debian:bookworm

# install php and extensions
# refresh package index
RUN apt-get update \
    # install php and extensions
    && apt-get install -y php php-mysqli php-fpm php-cli wget curl tar \
    # cleanup apt caches to reduce image size
    && rm -rf /var/lib/apt/lists/*

# config php-fpm to listen on port 9000 from all interfaces
RUN sed -i 's/listen =.*/listen = 9000/g' /etc/php/8.2/fpm/pool.d/www.conf

# create startup script
COPY tools/init_wordpress.sh /init_wordpress.sh
RUN chmod +x /init_wordpress.sh

# listen on port 9000 (to talk to nginx)
EXPOSE 9000

# run the php-fpm as foreground mode
ENTRYPOINT [ "/init_wordpress.sh" ]

# copy the create wp-config script
COPY tools/setup_wp_config.sh /setup_wp_config.sh
RUN chmod +x /setup_wp_config.sh && /setup_wp_config.sh
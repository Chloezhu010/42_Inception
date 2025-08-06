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

# downoad wordpress
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /var/www/ \
    && rm /tmp/wordpress.tar.gz

# set permissions
RUN chown -R www-data:www-data /var/www/wordpress

# listen on port 9000 (to talk to nginx)
EXPOSE 9000

# run the php-fpm as foreground mode
CMD ["php-fpm8.2", "-F"]
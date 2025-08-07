#!/bin/bash

# check if wordpress is already installed
if [ ! -f "/var/www/wordpress/wp-config-sample.php" ]; then
    echo "Wordpress not found, downloading..."
    # download and extract wordpress
    wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz -C /tmp
    # move wordpress files to the correct location
    cp -r /tmp/wordpress/* /var/www/wordpress/
    # remove the downloaded tar file
    rm -rf /tmp/wordpress.tar.gz /tmp/wordpress

    echo "Wordpress downloaded and extracted."
else
    echo "Wordpress already installed."
fi

# create wp-config.php if it does not exist
if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    echo "Creating wp-config.php..."
    # copy the sample config file
    cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
    # replace placeholders with environment variables
    sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/wordpress/wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" /var/www/wordpress/wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" /var/www/wordpress/wp-config.php
    sed -i "s/localhost/mariadb/" /var/www/wordpress/wp-config.php

    echo "wp-config.php created successfully."
fi

# set correct permissions
chown -R www-data:www-data /var/www/wordpress
chown -R 755 /var/www/wordpress

# start php-fpm in foreground
echo "Starting PHP-FPM..."
exec php-fpm8.2 -F
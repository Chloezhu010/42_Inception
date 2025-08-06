#!/bin/bash

# check if wordpress is already installed
if [ ! -f "/var/www/wordpress/wg-config-sample.php" ]; then
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

# set correct permissions
chown -R www-data:www-data /var/www/wordpress
chown -R 755 /var/www/wordpress

# start php-fpm in foreground
echo "Starting PHP-FPM..."
exec php-fpm8.2 -F
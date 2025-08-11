#!/bin/bash

# read secrets from files
MYSQL_PASSWORD=$(cat /run/secrets/db_password.txt)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password.txt)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password.txt)

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

    # add redis config to wp-config.php
    echo "Adding Redis configuration to wp-config.php..."
    cat >> /var/www/wordpress/wp-config.php << EOF
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
EOF
    echo "wp-config.php created successfully with redis config."
fi

# wait for mariadb to be ready
echo "Waiting for MariaDB to be ready..."
until mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
done
echo "MariaDB is ready."

# wait for redis to be ready
echo "Waiting for Redis to be ready..."
until php -r "
\$redis = new Redis();
try {
    \$redis->connect('redis', 6379);
    echo 'Redis connected successfully';
    \$redis->close();
    exit(0);
} catch (Exception \$e) {
    exit(1);
}
" >/dev/null 2>&1; do
    sleep 1
done
echo "Redis is ready."

# download wp-cli for wp mgmt
if [ ! -f "/usr/local/bin/wp" ]; then
    echo "Downloading WP-CLI..."
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /tmp/wp-cli.phar
    chmod +x /tmp/wp-cli.phar
    mv /tmp/wp-cli.phar /usr/local/bin/wp
fi

# change directory to wordpress
cd /var/www/wordpress
echo "Changed directory to $(pwd)"

# check if wordpress is installed
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "installing wordpress..."
    # install wordpress using wp-cli
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="42 Inception Wordpress" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
    # create a normal user
    echo "Creating normal user..."
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
    echo "Wordpress installed successfully."
else
    echo "Wordpress is already installed."
fi

# set correct permissions
chown -R www-data:www-data /var/www/wordpress
chmod -R 755 /var/www/wordpress

# install & activate redis cache plugin
echo "Installing Redis Cache plugin..."
wp plugin install redis-cache --activate --allow-root
wp redis enable --allow-root
# fix permissions for object-cache.php
chown www-data:www-data /var/www/wordpress/wp-content/object-cache.php
chmod 644 /var/www/wordpress/wp-content/object-cache.php
echo "Redis Cache plugin installed and activated."

# start php-fpm in foreground
echo "Starting PHP-FPM..."
exec php-fpm8.2 -F
#!/bin/bash

# start mariadb in the background
service mysql start

# create wordpress database
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"

# create normal wordpress user and grant privileges
# if the user already exists, it will not create a new one
mysql -u root -p$MYSQL_ROOT_PASSWORD -e \
    "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e \
    "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

# create admin user and grant privileges
mysql -u root -p$MYSQL_ROOT_PASSWORD -e \
    "CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e \
    "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%';"

# save changes: reload user permissions
# this is necessary to ensure that the new user and privileges are recognized
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

# stop mariadb
mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown

# launch mariadb in safe mode
exec mysqld_safe

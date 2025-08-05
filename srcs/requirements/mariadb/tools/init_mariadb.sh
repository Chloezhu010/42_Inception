#!/bin/bash

# ensure socket dir exists
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# check if this is the 1st run (no mysql system db)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # initialize the database directory
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    # start mariadb in the background
    mysqld_safe --user=mysql --skip-grant-tables &
    # wait for mariadb to start
    until mysqladmin ping --silent; do
        sleep 1
    done

    # set root password and create database and users
    mysql -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # stop temporary server
    mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown
fi

# launch mariadb in safe mode
# exec replaces the current shell with the command, making mysqld_safe PID 1
exec mysqld_safe

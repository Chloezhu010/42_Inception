#!/bin/bash

# ensure socket dir exists
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# check if this is the 1st run (no mysql system db)
DATABASE_EXITS=false
if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Custom database ${MYSQL_DATABASE} already exists"
    DATABASE_EXITS=true
else
    echo "Custom database ${MYSQL_DATABASE} does not exist, will create"
fi

# start mariadb temporarily to set up the database
echo "Starting MariaDB temporarily to set up the database..."
mysqld_safe --user=mysql &

# wait for mariadb to start
until mysqladmin ping --silent; do
    sleep 1
done
echo "MariaDB is ready!"

# read secrets from files
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password.txt)
MYSQL_PASSWORD=$(cat /run/secrets/db_password.txt)
MYSQL_ADMIN_PASSWORD=$(cat /run/secrets/db_admin_password.txt)

# set root password and create database and users
echo "Setting up root password, database and users..."
mysql -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "Database and users set up successfully!"

# stop temporary server
echo "Shutting down temporary MariaDB server..."
mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown

# launch mariadb in safe mode
echo "Starting MariaDB in production mode..."
# exec replaces the current shell with the command, making mysqld_safe PID 1
exec mysqld_safe --user=mysql

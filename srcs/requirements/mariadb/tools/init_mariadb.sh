#!/bin/bash

# check if dir exists & init
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Init MariaDB..."

    # init the db
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # temp mariadb start to config it
    mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking --skip-grant-tables &
    MYSQL_PID=$!

    # wait for mariadb to start
    echo "Wait for MariaDB to start..."
    until mysqladmin ping --silent; do
        sleep 1
    done
    echo "MariaDB started, config database..."

    # create the db and users
    mysql -u root << EOF
-- set root password
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');

-- create database
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- create user and grant privileges
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- create wordpress admin user
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_ADMIN_USER}'@'%';

-- remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- remove test database
DROP DATABASE IF EXISTS test;

-- flush privileges
FLUSH PRIVILEGES;
EOF

    # stop the temp mariadb instance
    kill $MYSQL_PID
    wait $MYSQL_PID

    echo "Database init complete"
    else
    echo "Database already init"
    fi

# start mariadb normally in foreground
echo "Starting MariaDB..."
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql

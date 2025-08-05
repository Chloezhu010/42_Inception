# base OS
FROM debian:bookworm

# install mariaDB
# refresh package index
RUN apt-get update \
    # install mariadb server
    && apt-get install -y mariadb-server \
    # cleanup apt caches to reduce image size
    && rm -rf /var/lib/apt/lists/*

# create mysql user and set permissions
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld

# copy init script into the container
COPY tools/init_mariadb.sh /init_mariadb.sh
RUN chmod +x /init_mariadb.sh

# config mariadb to listen on all interfaces
# RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# listen on port 3306 (mariadb default port)
EXPOSE 3306

# run the init script as the entrypoint
ENTRYPOINT ["/init_mariadb.sh"]
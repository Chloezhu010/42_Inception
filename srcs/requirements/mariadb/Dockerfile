# base OS
FROM debian:bookworm

# install mariaDB
RUN apt-get update \
    && apt-get install -y mariadb-server \
    # cleanup apt caches to reduce image size, eg. version nb, dependencies etc.
    && rm -rf /var/lib/apt/lists/*

# create dir for mariadb data (persistent data)
# incl. db file, table structures, indexes, log files, config state
RUN mkdir -p /var/lib/mysql \
    && chown -R mysql:mysql /var/lib/mysql

# create dir for run files (temp runtime files)
# incl. socket file, PID file, lock file
RUN mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld

# config db
COPY ./tools/init_mariadb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_mariadb.sh

# expose port
EXPOSE 3306

# run as mysql user
USER mysql

# CMD to run mariadb server directly
ENTRYPOINT ["/usr/local/bin/init_mariadb.sh"]
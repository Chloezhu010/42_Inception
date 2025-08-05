# base OS
FROM debian:bookworm

# install mariaDB
# refresh package index
RUN apt-get update \
    # install mariadb server
    && apt-get install -y mariadb-server \
    # cleanup apt caches to reduce image size
    && rm -rf /var/lib/apt/lists/*

# copy init script into the container
COPY tools/init_mariadb.sh /init_mariadb.sh
RUN chmod +x /init_mariadb.sh

# listen on port 3306 (mariadb default port)
EXPOSE 3306

# run the init script as the entrypoint
ENTRYPOINT ["/init_mariadb.sh"]

# # cmd to run when the container starts
# CMD ["mysqld_safe"]
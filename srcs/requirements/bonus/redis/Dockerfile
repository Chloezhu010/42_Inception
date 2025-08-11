# base OS
FROM debian:bookworm

# install redis
# refresh package index
RUN apt-get update \
    # install redis
    && apt-get install -y redis-server \
    # cleanup apt caches to reduce image size
    && rm -rf /var/lib/apt/lists/*

# copy redis config file
COPY conf/redis.conf /etc/redis/redis.conf

# copy redis init script and run it
COPY tools/init_redis.sh /init_redis.sh
RUN chmod +x /init_redis.sh

# expose redis port
EXPOSE 6379

# create redis data dir and set permissions
# for data storage and application logs
RUN mkdir -p /var/lib/redis \
    && chown redis:redis /var/lib/redis \
    && mkdir -p /var/log/redis \
    && chown redis:redis /var/log/redis

# run redis server
ENTRYPOINT [ "/init_redis.sh" ]

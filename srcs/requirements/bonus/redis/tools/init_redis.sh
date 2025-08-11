#!/bin/bash

echo "Initializing Redis..."
# set permission
chown -R redis:redis /var/lib/redis
chown -R redis:redis /var/log/redis

# start redis with config
exec redis-server /etc/redis/redis.conf --protected-mode no
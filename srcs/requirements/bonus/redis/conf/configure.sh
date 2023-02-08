#!/bin/bash

if ! [ -f "/etc/redis/redis.conf.original" ]; then

	cp /etc/redis/redis.conf /etc/redis/redis.conf.original

	sed -i -r "s/^bind 127.0.0.1/#bind 127.0.0.1/g" /etc/redis/redis.conf
	sed -i -r "s/^port [0-9]+$/port $REDIS_PORT/g" /etc/redis/redis.conf
	sed -i -r "s/^(#\s)?maxmemory <bytes>/maxmemory 20mb/g" /etc/redis/redis.conf
	sed -i -r "s/^(#\s)?maxmemory-policy noeviction/maxmemory-policy allkeys-lru/g" etc/redis/redis.conf
	sed -i -r "s/^daemonize yes/daemonize no/g" etc/redis/redis.conf
	sed -i -r "s/^protected-mode yes/protected-mode no/g" etc/redis/redis.conf

fi

exec "$@"

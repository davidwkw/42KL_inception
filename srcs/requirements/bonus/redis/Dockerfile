FROM debian:buster

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y lsb-release curl gpg\
	&& curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg \
	&& echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list \
	&& apt-get update -y \
	&& apt-get install -y redis

COPY ./conf/configure.sh /usr/local/bin/

ENTRYPOINT ["configure.sh"]

CMD ["redis-server", "/etc/redis/redis.conf"]

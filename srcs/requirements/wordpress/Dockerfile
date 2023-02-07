FROM debian:buster

EXPOSE 9000

RUN apt-get update \
	&& apt-get upgrade -y \
    && apt-get install -y wget php php-fpm php-mysql vim mariadb-client sendmail php7.3-redis \
	&& mkdir -p /run/php/

COPY ./conf/configure.sh /usr/local/bin/

COPY ./conf/index.html /tmp/

ENTRYPOINT ["configure.sh"]

CMD ["php-fpm7.3", "--nodaemonize"]

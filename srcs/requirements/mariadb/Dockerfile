FROM debian:buster

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y mariadb-server vim procps

COPY ./conf/configure.sh /usr/local/bin/

EXPOSE 3306

ENTRYPOINT ["configure.sh"]

CMD ["mysqld_safe"]

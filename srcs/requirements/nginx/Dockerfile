FROM debian:buster

RUN apt-get update \
	&& apt-get upgrade -y \
    && apt-get install -y nginx ufw openssl\
    && ufw allow "Nginx Full" \
    && ufw delete allow 'Nginx HTTP' \
    && mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=MY/ST=SGR/L=Selangor/O=/CN=$DOMAIN_NAME" \
    && chmod 400 /etc/ssl/private/nginx-selfsigned.key \
    && openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original

COPY ./conf/nginx.conf /etc/nginx/

COPY ./conf/kwang.42.fr.conf /etc/nginx/conf.d/

COPY ./conf/self-signed.conf /etc/nginx/snippets/

COPY ./conf/ssl-params.conf /etc/nginx/snippets/

COPY ./conf/configure.sh /usr/local/bin/

EXPOSE 443

ENTRYPOINT ["configure.sh"]

CMD ["nginx", "-g", "daemon off;"]

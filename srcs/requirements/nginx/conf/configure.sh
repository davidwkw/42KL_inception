#!/bin/bash

if ! [ -d "/var/www/" ]; then
	mkdir -p /var/www/
fi

echo "Configuring kwang.42.fr's server directives"
sed -i "s/\$DOMAIN_NAME/$DOMAIN_NAME/g" /etc/nginx/nginx.conf
sed -i "s/\$DOMAIN_NAME/$DOMAIN_NAME/g" /etc/nginx/conf.d/$DOMAIN_NAME.conf
sed -i "s/\$PHP_FPM_HOST/$WP_HOST/g" /etc/nginx/conf.d/$DOMAIN_NAME.conf
sed -i "s/\$PHP_FPM_PORT/$WP_PORT/g" /etc/nginx/conf.d/$DOMAIN_NAME.conf
echo "Finished setting up kwang.42.fr's server directives"

exec "$@"

#!/bin/bash

if ! [ -e "/usr/local/bin/wp" ]; then
	echo "Downloading wp cli..."
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
	echo "Finished downloading wp cli..."
fi

wp cli update

if ! [ -d "/var/www/" ]; then
	mkdir -p /var/www/
fi

cd /var/www/

if [ $(ls -1A /var/www/ | wc -l) -eq 0 ]; then
	echo "Setting up wordpress..."
	echo "Downloading wp core"
	wp core download --allow-root
	echo "Creating config"
	wp core config --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --dbhost=$DB_HOST --allow-root
	wp config set --allow-root WP_REDIS_HOST $REDIS_HOST
	wp config set --allow-root --raw WP_REDIS_PORT $REDIS_PORT
	wp config set --allow-root --raw WP_REDIS_TIMEOUT 1
	wp config set --allow-root --raw WP_REDIS_READ_TIMEOUT 1
	wp config set --allow-root --raw WP_REDIS_DATABASE 0
	chmod 644 wp-config.php
	echo "Installing core"
	wp core install --url=$DOMAIN_NAME --title=$WP_TITLE --admin_user=$WP_ADMIN_USERNAME --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --allow-root
	echo "Changing permissions"
	mv /tmp/index.html /var/www/
	if ! wp user get $WP_USER_EMAIL --field=ID --quiet --allow-root &> /dev/null; then
		wp user create $WP_USER $WP_USER_EMAIL --role=$WP_USER_ROLE --user_pass=$WP_USER_PASSWORD --allow-root --quiet
	fi
	wp plugin install redis-cache --activate --allow-root
	echo "Enabling redis cache.."
	wp redis enable --allow-root
	echo "Finished setting up wordpress"
fi

echo "Updating wordpress plugins"
wp plugin update --all --allow-root

echo "Setting up fpm-cgi pool config..."
sed -i "s/^\s*listen\s*=\s*.*/listen = $WP_PORT/g" /etc/php/7.3/fpm/pool.d/www.conf
sed -i "s/^;\s*ping.path\s*=\s*\/ping/ping.path = \/ping/g" /etc/php/7.3/fpm/pool.d/www.conf
sed -i "s/^;\s*ping.response\s*=\s*pong/ping.response = pong/g" /etc/php/7.3/fpm/pool.d/www.conf
echo "Finished setting up fpm-cgi"

exec "$@"

#!/bin/bash

if ! [ -d "/run/mysqld" ]; then
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
fi

if ! [ -d "/var/lib/mysql/mysql" ]; then
	echo "Installing mariadb..."
	mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql > /dev/null
	mysqld_safe --loose-innodb_buffer_pool_load_at_startup=0 --skip-networking --expire-logs-days=0 &

	while ! mysqladmin ping --silent; do
		sleep 1
	done

	echo "Checking if root user has password..."
	mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD';"
	mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

	echo "Performing secure install statements..."
	mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "DELETE FROM mysql.user WHERE User='';"
	mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
	mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS test;"
	mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
	mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

	echo "Database and user creation...."
	mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
	mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
	mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
	mysql -u root --password=$MARIADB_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
	echo "Finished configuring initial mariadb setup"

	echo "Sending kill signal to mysqld background process"
	killall -w mysqld
	echo "mysqld background process successfully killed"
fi

echo "Configuring mariadb networking..."
sed -i -r "s/^\s*#?\s*bind-address\s*=.*/bind-address = 0.0.0.0/g" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i -r "s/^\s*skip-networking\s*(=\s*[0-9]*)?$/#skip-networking/g" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i -r "s/^\s*#?\s*port\s*=\s*[0-9]*/port = $DB_PORT/g" /etc/mysql/mariadb.conf.d/50-server.cnf
echo "Finished configuring mariadb networking..."

exec "$@"

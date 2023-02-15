COMPOSE_PROJECT_NAME = inception
NETWORK_NAME = test

create-network:
	docker network create $(NETWORK_NAME)

build-db:
	docker build -t mariadb-test ./srcs/requirements/mariadb/.

run-db: build-db
	docker run -p 3306:3306 --network test --network-alias mariadb --mount type=volume,src=db-data,target=/var/lib/mysql --env-file ./srcs/.env -dit --name mariadb-t mariadb-test

build-wp:
	docker build -t wordpress-test ./srcs/requirements/wordpress/.

run-wp: build-wp
	docker run -p 9000:9000 --network test --network-alias wordpress --mount type=volume,src=wp-file-data,target=/wordpress --env-file ./srcs/.env -dit --name wordpress-t wordpress-test

build-nginx:
	docker build -t nginx-test ./srcs/requirements/nginx/.

run-nginx: build-nginx
	docker run -dit -p 443:443 --env-file ./srcs/.env --name nginx nginx-test

compose:
	docker compose up -d --build

clean:
	docker compose down

fclean:
	docker compose down

re:	clean compose

.PHONY : all clean fclean re


.PHONY: debug

update:
	bash update.sh

up: update
	docker-compose up --build -d vtiger

debug: up
	docker-compose exec vtiger debug

release: update
	bash release.sh

xdebug: up
	docker-compose logs -f xdebug

## =====
## Tests
## =====
test-vtiger: update
	@docker-compose up --build --force-recreate -d vtiger
	@echo "Visit: <http://localhost:8080>"

test-debug: update
	docker run -t -i --rm -v ${PWD}:/app javanile/vtiger-dev:7.1.0 debug

test-debug-polling: update
	docker run -t -i --rm -v ${PWD}:/app javanile/vtiger-dev:7.1.0 debug --polling

test-debug-disable-watch: update
	docker run -t -i --rm -v ${PWD}:/app javanile/vtiger-dev:7.1.0 debug --disable-watch

test-xdebug: update
	#docker run -t -i --rm -v ${PWD}:/app javanile/vtiger-dev:7.1.0 cat /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
	#docker run -t -i --rm -v ${PWD}:/app javanile/vtiger-dev:7.1.0 php --ini
	docker run -t -i --rm -v ${PWD}:/app javanile/vtiger-dev:7.1.0

test-mysql: update up
	docker-compose run --rm vtiger bash -c "mysql -hmysql -uroot -psecret vtiger -e 'SHOW TABLES'"

test-phpunit: update up
	docker-compose run --rm vtiger phpunit /var/www/html/test/VtigerTest.php

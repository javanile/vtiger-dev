
.PHONY: debug

update:
	bash contrib/update.sh

build: update
	docker-compose build vtiger

up: update
	docker-compose up --build -d vtiger

ps:
	docker-compose ps

pull:
	docker-compose pull --include-deps

debug: up
	docker-compose exec vtiger debug

release: update
	bash release.sh

xdebug: up
	docker-compose logs -f xdebug

bash:
	@docker-compose exec vtiger bash

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

test-profiler: update
	#docker run -t -i --rm -v ${PWD}:/app javanile/vtiger-dev:7.1.0 cat /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
	#docker run -t -i --rm -v ${PWD}:/app javanile/vtiger-dev:7.1.0 php --ini
	docker run -t -i --rm -v ${PWD}:/app javanile/vtiger-dev:7.1.0

test-mysql: update up
	docker-compose run --rm vtiger bash -c "mysql -hmysql -uroot -psecret vtiger -e 'SHOW TABLES'"

test-phpunit: update up
	docker-compose run --rm vtiger phpunit /var/www/html/test/VtigerTest.php

test-phpmd: update up
	docker-compose run --rm vtiger phpmd --help

test-websocket: update up
	uwsc ws://localhost:8080/websocket-test.php

test-foreground: pull update up
	docker compose up --build --force-recreate vtiger

test-gd: build
	docker compose run --rm vtiger php -r "imagejpeg();"

test-phpdbg: build
	docker compose run --rm vtiger phpdbg

test-intl: build
	@docker compose run --rm vtiger php -r "var_dump(new Spoofchecker());"

test-pcov: build
	docker compose run --rm vtiger pcov --coverage-html=tmp/coverage-report .

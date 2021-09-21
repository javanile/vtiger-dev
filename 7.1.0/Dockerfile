FROM javanile/vtiger:7.1.0

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y --no-install-recommends inotify-tools wget zip unzip vim nano iputils-ping gettext mysql-client libldap2-dev && \
   	ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so && \
   	docker-php-ext-install ldap && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && apt-get install -y --no-install-recommends tidy libtidy-dev && docker-php-ext-install tidy

RUN	( pecl install -f xdebug-2.7.2 || pecl install -f xdebug-2.5.5 ) && docker-php-ext-enable xdebug

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -sL -o /usr/local/bin/phpcs https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar && chmod +x /usr/local/bin/phpcs
RUN curl -sL -o /usr/local/bin/phpcbf https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar && chmod +x /usr/local/bin/phpcbf
RUN curl https://phar.phpunit.de/phpunit-6.phar -L -o /usr/local/bin/phpunit && chmod +x /usr/local/bin/phpunit
RUN curl -sL https://javanile.github.io/inotifywait-polling/setup.sh | bin=/usr/local/bin/inotifywait-polling bash -

COPY VtigerTest.php /var/www/html/VtigerTest.php
COPY debug.sh /usr/local/bin/debug
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY xdebug-test.php /var/www/html/xdebug-test.php

RUN echo "<?php phpinfo();" > /var/www/html/phpinfo.php

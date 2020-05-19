FROM javanile/vtiger:7.1.0

ENV XDEBUG_CONFIG="xdebug.idekey=''"

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y --no-install-recommends inotify-tools zip unzip vim nano && \
	pecl install -f xdebug-2.7.2 && \
	docker-php-ext-enable xdebug && \
    echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.remote_autostart = 0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.remote_connect_back = 0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.remote_port = 9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.remote_handler = 'dbgp'" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.remote_mode = req" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -sL -o /usr/local/bin/phpcs https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar && chmod +x /usr/local/bin/phpcs
RUN curl -sL -o /usr/local/bin/phpcbf https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar && chmod +x /usr/local/bin/phpcbf
RUN curl https://phar.phpunit.de/phpunit.phar -L -o /usr/local/bin/phpunit && chmod +x /usr/local/bin/phpunit
RUN curl -sL https://javanile.github.io/inotifywait-polling/setup.sh | bin=/usr/local/bin/inotifywait-polling bash -

COPY debug.sh /usr/local/bin/debug

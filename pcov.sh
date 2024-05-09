#!/usr/bin/env bash

php -d pcov.enabled=1 /usr/local/bin/phpunit "$@"

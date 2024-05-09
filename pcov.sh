#!/usr/bin/env bash

php \
    -d pcov.enabled=1 \
    -d pcov.directory=/app \
    /usr/local/bin/phpunit "$@"

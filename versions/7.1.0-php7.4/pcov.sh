#!/usr/bin/env bash

PCOV_DIR=${PCOV_DIR:-/app}

php \
    -d xdebug.mode=off \
    -d pcov.enabled=1 \
    -d pcov.directory=${PCOV_DIR} \
    /usr/local/bin/phpunit "$@"

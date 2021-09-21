#!/usr/bin/env bash
set -e

source versions.sh

for version in "${versions[@]}"; do
  mkdir -p ${version}
  sed -e 's!%{version}!'"${version}"'!' Dockerfile.template > ${version}/Dockerfile
  cp VtigerTest.php ${version}/VtigerTest.php
  cp debug.sh ${version}/debug.sh
  cp xdebug.ini ${version}/xdebug.ini
  cp xdebug-test.php ${version}/xdebug-test.php
  chmod +x ${version}/debug.sh
  docker build -t javanile/vtiger-dev:${version} ${version}
done

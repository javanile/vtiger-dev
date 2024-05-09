#!/usr/bin/env bash
set -e

source versions.sh

for version in "${versions[@]}"; do
  mkdir -p "versions/${version}"
  sed -e 's!%{version}!'"${version}"'!' Dockerfile.template > "versions/${version}/Dockerfile"
  cp VtigerTest.php "versions/${version}/VtigerTest.php"
  cp debug.sh "versions/${version}/debug.sh"
  cp xdebug.ini "versions/${version}/xdebug.ini"
  cp xdebug-test.php "versions/${version}/xdebug-test.php"
  cp websocket-test.php "versions/${version}/websocket-test.php"
  chmod +x "versions/${version}/debug.sh"
  docker build -t "javanile/vtiger-dev:${version}" "versions/${version}"
done

#!/usr/bin/env bash

source versions.sh

for version in "${versions[@]}"; do
  mkdir -p ${version}
  sed -e 's!%{version}!'"${version}"'!' Dockerfile.template > ${version}/Dockerfile
  cp debug.sh ${version}/debug.sh
  chmod +x ${version}/debug.sh
  docker build -t javanile/vtiger-dev:${version} ${version}
done

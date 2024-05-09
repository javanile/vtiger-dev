#!/usr/bin/env bash
set -e

VERSION=0.$(date +%y.%U)

docker login --username yafb

source contrib/versions.sh

for version in "${versions[@]}"; do
  docker build -t "javanile/vtiger-dev:${version}" "versions/${version}"
  docker push "javanile/vtiger-dev:${version}"
done

git add .
git commit -am "Release ${VERSION}" && true
git push

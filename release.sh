#!/usr/bin/env bash
set -e

VERSION=0.$(date +%y.%U)

docker login --username javanile

source versions.sh

for version in "${versions[@]}"; do
  docker build -t javanile/vtiger-dev:${version} ${version}
  docker push javanile/vtiger-dev:${version}
done

git add .
git commit -am "Release ${VERSION}" && true
git push

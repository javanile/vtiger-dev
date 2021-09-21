#!/usr/bin/env bash
set -e

docker login --username javanile

source versions.sh

for version in "${versions[@]}"; do
  docker build -t javanile/vtiger-dev:${version} ${version}
  docker push javanile/vtiger-dev:${version}
done

git add .
git commit -am "new release"
git push

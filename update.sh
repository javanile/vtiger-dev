#!/usr/bin/env bash

versions=(
  7.1.0
)

for version in "${versions[@]}"; do
  mkdir -p ${version}
  sed -e 's!%{version}!'"${version}"'!' Dockerfile.template > ${version}/Dockerfile
  cp debug.sh ${version}/debug.sh
  chmod +x ${version}/debug.sh
  docker build -t javanile/vtiger-dev:${version} ${version}
  docker push javanile/vtiger-dev:${version}
done

git add .
git commit -am "new release"
git push

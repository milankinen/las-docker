#!/usr/bin/env bash

image_name="$(cat IMAGE)"
version="$(cat VERSION)"

docker tag ${image_name}:${version} ${image_name}:latest
docker push ${image_name}:${version}
docker push ${image_name}:latest

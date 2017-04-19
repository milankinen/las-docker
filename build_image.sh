#!/usr/bin/env bash
set -eu pipefail

image_name="$(cat IMAGE)"
version="$(cat VERSION)"

echo "Downloading dependency libraries..."
mkdir -p lib
if [ ! -f lib/anna-3.6.jar ]; then
  curl -L -o lib/anna-3.6.jar https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mate-tools/anna-3.6.jar
fi


echo "Building version $version..."

# without --squash the image size would be ~18G
docker build \
        -t ${image_name}:${version} \
        --squash \
        .


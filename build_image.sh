#!/usr/bin/env bash
set -eu pipefail

image_name="$(cat IMAGE)"
version="$(cat VERSION)"

echo "Downloading dependency libraries..."
mkdir -p lib
if [ ! -f lib/anna-3.6.jar ]; then
  curl -L -o lib/anna-3.6.jar https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mate-tools/anna-3.6.jar
fi
if [ ! -f lib/marmot-2014-10-22.jar ]; then
  curl -L -o lib/marmot-2014-10-22.jar https://github.com/TurkuNLP/Finnish-dep-parser/raw/master/LIBS-LOCAL/marmot/marmot-2014-10-22.jar
fi


echo "Building version $version..."

# without --squash the image size would be ~18G
docker build \
        -t ${image_name}:${version} \
        --squash \
        .


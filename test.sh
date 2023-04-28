#!/bin/sh

set -e

cleanup() {
  echo "Stopping Docker image"
  docker stop test
}

echo "Running Docker image"
docker run -d --name test --rm -p 9001:9001 "${CI_REGISTRY_IMAGE}:${TAG}"
trap cleanup EXIT

echo "Sleeping"
sleep 10

echo "Testing"
wget -q -O - http://docker:9001 | grep -q '<title>Etherpad</title>'

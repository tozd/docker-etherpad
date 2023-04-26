#!/bin/sh

echo "Running Docker image"
docker run -d --name test --rm -p 9001:9001 "${CI_REGISTRY_IMAGE}:${TAG}" || exit 1

echo "Sleeping"
sleep 10

echo "Testing"
wget -q -O - http://docker:9001 | grep -q '<title>Etherpad</title>'
result=$?

echo "Stopping Docker image"
docker stop test

exit "$result"
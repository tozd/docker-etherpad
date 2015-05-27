#!/bin/bash -e

# An example script to run Etherpad in production. It uses data volumes under the $DATA_ROOT directory.
# By default /srv. It uses a PostgreSQL database. The first time you have to create a database itself
# and account with permissions over it. In Etherpad settings you can use __DB_HOST__ placeholder which
# will be replaced with host and port of a linked PostgreSQL container. The first time you run this
# script it will create a default settings.json file on the host for you at $ETHERPAD_SETTINGS.

SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"

export NAME='etherpad'
export DATA_ROOT='/srv'
export POSTGRESQL_DATA="${DATA_ROOT}/${NAME}/postgresql/data"
export POSTGRESQL_LOG="${DATA_ROOT}/${NAME}/postgresql/log"

export ETHERPAD_LOG="${DATA_ROOT}/${NAME}/etherpad/log"
export ETHERPAD_SETTINGS="${DATA_ROOT}/${NAME}/settings.json"

mkdir -p "$POSTGRESQL_DATA"
mkdir -p "$POSTGRESQL_LOG"
mkdir -p "$ETHERPAD_LOG"

if [ -f "${SCRIPT_DIR}/etherpad-lite/settings.json.template" ] && [ ! -f "$ETHERPAD_SETTINGS" ]; then
  cp "${SCRIPT_DIR}/etherpad-lite/settings.json.template" "$ETHERPAD_SETTINGS"
fi

docker stop "${NAME}_postgresql" || true
sleep 1
docker rm "${NAME}_postgresql" || true
sleep 1
docker run --detach=true --restart=always --name "${NAME}_postgresql" --volume "${POSTGRESQL_LOG}:/var/log/postgresql" --volume "${POSTGRESQL_DATA}:/var/lib/postgresql" tozd/postgresql

# If you are running the PostgreSQL image for the first time with its data volume, you should configure the
# database. Exec into the Docker container and run the following example commands to create user "etherpad"
# with database "etherpad", by default:
#
# docker exec -t -i etherpad_postgresql /bin/bash
#
# createuser -U postgres -DRS -P etherpad
# createdb -U postgres -O etherpad etherpad

docker stop "${NAME}_etherpad" || true
sleep 1
docker rm "${NAME}_etherpad" || true
sleep 1
docker run --detach=true --restart=always --name "${NAME}_etherpad" --env VIRTUAL_HOST="${NAME}.tnode.com" --env VIRTUAL_URL=/ --volume "${ETHERPAD_LOG}:/var/log/etherpad" --volume "${ETHERPAD_SETTINGS}:/etc/etherpad.json" --link "${NAME}_postgresql:db" tozd/etherpad

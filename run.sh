#!/bin/bash -e

# An example script to run Etherpad in production. It uses data volumes under the $DATA_ROOT directory.
# By default /srv.

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

function container_running() {
  local name="$1"

  local running=$(docker inspect --format="{{ .State.Running }}" "$name" 2> /dev/null)
  if [ $? -eq 1 ]; then
    # Container does not exist.
    return 2
  fi
  if [ "$running" == "true" ]; then
    # Container is running.
    return 0
  fi
  # Container is not running.
  return 1
}

function container_stopped() {
  local name="$1"

  local running=$(docker inspect --format="{{ .State.Running }}" "$name" 2> /dev/null)
  if [ $? -eq 1 ]; then
    # Container does not exist.
    return 2
  fi
  if [ "$running" == "false" ]; then
    # Container is not running.
    return 0
  fi
  # Container is running.
  return 1
}

function run_or_start() {
  local name="$1"
  shift
  
  if container_stopped "$name"; then
    echo "Starting '$name'"
    docker start "$name"
  elif ! container_running "$name"; then
    echo "Running '$name'"
    docker run --detach=true --restart=always --name "$name" "$@"
  else
    echo "Already running '$name'"
    return 0
  fi
}

#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

./run.sh

exe=lib/main.js

log=/var/log/crontab/ssl
mkdir -p $log

job="$((59 * RANDOM / 32768)) $((24 * RANDOM / 32768)) */10 * * eval \$(rtx env) && cd $DIR && timeout 1h $exe > $log/$(basename $DIR).log 2>&1"

crontab -l | (
  cat | grep -v -F $DIR
  echo "$job"
) | crontab -

crontab -l | cat

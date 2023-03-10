#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

# ./run.sh

exe=lib/ssl.js

job="0 3 */10 * * eval \$(rtx env) && cd $DIR && timeout 1h $exe > /var/log/crontab.ssl.log 2>&1"

crontab -l | (
  cat | grep -v -F $DIR
  echo "$job"
) | crontab -

crontab -l | cat

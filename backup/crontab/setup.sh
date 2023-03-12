#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

job="$((59 * RANDOM / 32768)) $((24 * RANDOM / 32768)) * * * $DIR/crontab/backup.sh"

crontab -l | (
  cat | grep -v -F $DIR
  echo "$job"
) | crontab -

crontab -l | cat

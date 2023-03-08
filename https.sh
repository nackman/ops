#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR

if [ -v 1 ]; then
  HOST=$1
else
  echo "USAGE : $0 xxx.xxx"
  exit 1
fi

set -ex

export HOME=/mnt/www

acme=$HOME/.acme.sh/acme.sh

if [ ! -x "$acme" ]; then
  export ACME_GIT=usrtax/acme.sh
  curl https://ghproxy.com/https://raw.githubusercontent.com/usrtax/get.acme.sh/master/index.html | sh -s email=$EMAIL
  $acme --upgrade --auto-upgrade
fi

reload="$DIR/reload/$HOST.sh"

cp $DIR/.reload.sh $reload

if [ -f "$HOME/.acme.sh/$HOST/fullchain.cer" ]; then
  echo "update $HOST"
  $acme --force --renew -d $HOST -d *.$HOST --log --reloadcmd "$reload"
else
  echo "refresh $HOST"
  $acme \
    --days 30 --issue --dns dns_$DNS -d $HOST -d *.$HOST --force --log --reloadcmd "$reload"
fi

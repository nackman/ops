#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR

if [ ! -f "conf.sh" ]; then
  echo -e "cp conf.example.sh conf.sh\nthen edit it"
  exit 1
fi

source conf.sh
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
  curl https://ghproxy.com/https://raw.githubusercontent.com/usrtax/get.acme.sh/master/index.html | sh -s email=$MAIL
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

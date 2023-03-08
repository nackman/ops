#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR

CONF=$(./env.sh)

conf=$CONF/conf.sh

if [ ! -f "$conf" ]; then
  cp conf.example.sh $conf
fi

source $conf

if [[ -z $DNS ]]; then
  echo -e "please edit $conf"
  exit 1
fi

if [ -v 1 ]; then
  HOST=$1
else
  echo "USAGE : $0 example.com"
  exit 1
fi

set -ex

export HOME=/mnt/www

acme=$HOME/.acme.sh/acme.sh

if [ ! -x "$acme" ]; then
  curl https://ghproxy.com/https://raw.githubusercontent.com/usrtax/get.acme.sh/master/index.html | sh -s email=$MAIL
  $acme --upgrade --auto-upgrade
fi

mkdir -p $CONF/reload

reload="$CONF/reload/$HOST.sh"

if [ ! -f "$reload" ]; then
  cp $DIR/.reload.sh $reload
fi

gen() {
  if [ -f "$HOME/.acme.sh/$HOST_ecc/fullchain.cer" ]; then
    echo "update $HOST"
    $acme --force --renew -d $HOST -d *.$HOST --log --reloadcmd "$reload"
  else
    echo "refresh $HOST"
    $acme \
      --days 30 --issue --dns dns_$DNS -d $HOST -d *.$HOST \
      --force --log --reloadcmd "$reload"
  fi
}

gen || gen

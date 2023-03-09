#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR

CONF=$(./env.sh)

conf=$CONF/conf.sh

if [ ! -f "$conf" ]; then
  cp conf.example.sh $conf
fi

source $conf

if [ ! $DNS ]; then
  echo -e "\nPLEASE EDIT :\n$conf\n"
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

fullchain=$HOME/.acme.sh/${HOST}_ecc/fullchain.cer
gen() {
  if [ -f "$fullchain" ]; then
    echo "update $HOST"
    # 获取文件的修改时间并将其转换为 UNIX 时间戳
    file_modified_time=$(stat -c %Y "$fullchain")
    # 获取当前时间的 UNIX 时间戳
    current_time=$(date +%s)
    # 计算文件修改时间和当前时间之间的时间差
    time_diff=$((current_time - file_modified_time))
    # 如果时间差小于一天的秒数，则文件在一天内被修改过
    if [ "$time_diff" -lt 86400 ]; then
      echo "$fullchain updated today"
    else
      $acme --force --renew -d $HOST -d *.$HOST --log --reloadcmd "$reload"
    fi
  else
    echo "refresh $HOST"
    $acme \
      --days 30 --issue --dns dns_$DNS -d $HOST -d *.$HOST \
      --force --log --reloadcmd "$reload"
  fi
}

gen || gen

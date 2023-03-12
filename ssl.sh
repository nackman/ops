#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR

HOST=$1

CONF=$(./env.sh)

conf=$CONF/conf.sh

if [ ! -f "$conf" ]; then
  cp .conf.sh $conf
fi

source $conf

if [ ! $DNS ]; then
  echo -e "\nPLEASE EDIT :\n$conf\n"
  exit 1
fi

if [ -z "$HOST" ]; then
  echo "USAGE : $0 example.com"
  exit 1
fi

set -ex

export HOME=/mnt/www
export LE_WORKING_DIR=$HOME/.acme.sh
# export DEBUG=1

ACME_DIR=$HOME/.acme.sh
acme=$ACME_DIR/acme.sh

ACME_DIR_ENV=$ACME_DIR/acme.sh.env

if [ ! -x "$acme" ]; then
  if ! curl -I --connect-timeout 1 -m 3 -s https://t.co >/dev/null; then
    GHPROXY=https://ghproxy.com/
  fi
  cd /tmp
  curl ${GHPROXY}https://raw.githubusercontent.com/usrtax/acme.sh/master/acme.sh | sh -s -- --install-online --email $MAIL
  $acme --upgrade --auto-upgrade
fi

mkdir -p $CONF/reload

reload="$CONF/reload/$HOST.sh"

if [ ! -f "$reload" ]; then
  cp $DIR/.reload.sh $reload
fi

fullchain=$HOME/.acme.sh/${HOST}_ecc/fullchain.cer
dnssleep="--dnssleep 25"
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
      $acme $dnssleep \
        --force --renew \
        -d $HOST -d *.$HOST --log --reloadcmd "$reload"
    fi
  else
    echo "init $HOST"
    $acme \
      --dns dns_$DNS \
      --days 30 --issue \
      -d $HOST -d *.$HOST \
      --force \
      $dnssleep \
      --log --reloadcmd "$reload"
  fi
}

gen || gen

if ! [ -x "$(command -v setfacl)" ]; then
  apt-get install -y acl
fi

can_read() {
  id -u $1 &>/dev/null && setfacl -R -m u:$1:rX $LE_WORKING_DIR
}

can_read www-data
can_read mail

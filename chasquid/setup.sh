#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

if [ -v 1 ]; then
  HOST=$1
else
  echo "USAGE : $0 example.com"
  exit 1
fi

../ssl.sh $HOST

if ! [ -x "$(command -v chasquid)" ]; then
  cd /tmp
  rm -rf chasquid
  git clone https://blitiri.com.ar/repos/chasquid
  cd chasquid
  make
  make install-binaries
  make install-config-skeleton
fi

if ! [ -x "$(command -v setfacl)" ]; then
  apt-get install -y acl
fi

user=chasquid
id -u $user || useradd -s /bin/false $user

setfacl -R -m u:$user:rX /mnt/www/.acme.sh

for i in dkimsign dkimverify dkimkeygen; do
  if ! [ -x "$(command -v $i)" ]; then
    go install github.com/driusan/dkim/cmd/$i@latest
  fi
done

CONF=$(../env.sh)

conf=$CONF/chasquid
rm -rf /etc/chasquid
mkdir -p $conf
ln -s $conf /etc/chasquid

cert=$conf/certs/$HOST
mkdir -p $cert
cd $cert
if [ ! -f "dkim_privkey.pem" ]; then
  dkimsign
fi

chown -R chasquid $conf

cd $DIR

systemctl enable chasquid --now
systemctl restart chasquid

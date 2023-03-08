#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

cd /tmp
rm -rf chasquid
git clone https://blitiri.com.ar/repos/chasquid
cd chasquid
make
make install-binaries
make install-config-skeleton
systemctl enable --now chasquid

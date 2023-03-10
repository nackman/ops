#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

if [ ! -d "node_modules" ]; then
  pnpm i
fi

./ssl.coffee

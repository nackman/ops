#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

init() {
  if [ ! -d $1/node_modules ]; then
    if ! [ -x "$(command -v pnpm)" ]; then
      npm install -g pnpm
    fi
    cd $1
    pnpm i
    cd $DIR
  fi
}

init $DIR

if [ -n "$1" ]; then
  init $1
fi

#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
CONF=$(dirname $DIR)/conf
mkdir -p $CONF
echo $CONF

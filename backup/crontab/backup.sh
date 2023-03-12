#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

BACKUP=/mnt/backup/crontab
mkdir -p $BACKUP

crontab -l >$BACKUP/$(hostname).txt

#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

BACKUP=/mnt/backup/crontab
mkdir -p $BACKUP

txt=$(hostname).txt
crontab -l >$BACKUP/$txt
cd $BACKUP
git add $txt
gitsync

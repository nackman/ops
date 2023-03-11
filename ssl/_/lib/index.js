#!/usr/bin/env -S node --loader=@u6x/jsext --trace-uncaught --expose-gc --unhandled-rejections=strict --experimental-import-meta-resolve
var TODAY, sslIter;

import {
  join
} from 'path';

import {
  readdirSync,
  existsSync,
  statSync
} from 'fs';

import read from '@u7/read';

TODAY = new Date();

export var ACME = '/mnt/www/.acme.sh';

export const fullchainFp = (name) => {
  return join(ACME, name, 'fullchain.cer');
};

sslIter = function*(exist) {
  var i, name, ref;
  ref = readdirSync(ACME, {
    withFileTypes: true
  });
  for (i of ref) {
    if (i.isDirectory()) {
      ({name} = i);
      if (name.includes('.')) {
        if (existsSync(fullchainFp(name))) {
          yield name;
        }
      }
    }
  }
};

export const hostDir = () => {
  var exist, host, i, ref;
  exist = new Map();
  ref = sslIter();
  for (i of ref) {
    if (i.endsWith('_ecc')) {
      host = i.slice(0, -4);
    } else {
      host = i;
    }
    exist.set(host, i);
  }
  return exist;
};

export const certKey = (dir, host) => {
  var day, key, mtime, name, stats;
  key = join(ACME, dir, host + '.key');
  stats = statSync(key);
  mtime = new Date(stats.mtime);
  day = (TODAY - mtime) / 86e6;
  if (day >= 90) {
    console.error(`TODO : ${dir} 证书过期了`);
    return;
  }
  name = host + "_" + mtime.toISOString().slice(0, 10);
  return [name, read(fullchainFp(dir)), read(key)];
};

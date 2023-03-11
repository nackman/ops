#!/usr/bin/env -S node --loader=@u6x/jsext --trace-uncaught --expose-gc --unhandled-rejections=strict --experimental-import-meta-resolve
var sslIter;

import {
  join
} from 'path';

import {
  readdirSync,
  existsSync
} from 'fs';

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

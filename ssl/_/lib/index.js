#!/usr/bin/env -S node --loader=@u6x/jsext --trace-uncaught --expose-gc --unhandled-rejections=strict --experimental-import-meta-resolve
var TODAY, sslIter, uploadSet;

import {
  join
} from 'path';

import {
  readdirSync,
  existsSync,
  statSync
} from 'fs';

import read from '@u7/read';

import '@u7/default';

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
  var day, fullfp, key, mtime, name, stats;
  fullfp = fullchainFp(dir);
  key = join(ACME, dir, host + '.key');
  stats = statSync(fullfp);
  mtime = new Date(stats.mtime);
  day = (TODAY - mtime) / 86e6;
  if (day >= 90) {
    console.error(`TODO : ${dir} 证书过期了`);
    return;
  }
  name = host + "_" + mtime.toISOString().slice(0, 10);
  return [name, read(fullfp), read(key)];
};

uploadSet = async(upload, set, host, dir, host_li) => {
  var name, r, v;
  r = certKey(dir, host);
  if (!r) {
    return;
  }
  v = (await upload(host, ...r));
  name = r[0];
  await Promise.all(host_li.map((i) => {
    console.log(i, '→', name);
    return set(i, name, v);
  }));
};

export const bind = async(cdnLs, upload, set) => {
  var add, dir, domain_dir, host_dir, host_li, i, name, ref, ref1, x;
  host_dir = hostDir();
  domain_dir = new Map();
  add = () => {
    if (host_dir.has(name)) {
      domain_dir.default(name, () => {
        return [];
      }).push(i);
      return true;
    }
  };
  ref = (await cdnLs());
  for (i of ref) {
    if (i.startsWith('.')) {
      name = i.slice(1);
    } else {
      name = i;
    }
    if (!add()) {
      name = name.slice(name.indexOf('.') + 1);
      add();
    }
  }
  ref1 = domain_dir.entries();
  for (x of ref1) {
    [name, host_li] = x;
    dir = host_dir.get(name);
    await uploadSet(upload, set, name, dir, host_li);
  }
};

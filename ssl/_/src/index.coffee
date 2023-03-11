#!/usr/bin/env coffee

> path > join
  fs > readdirSync existsSync

< ACME = '/mnt/www/.acme.sh'

< fullchainFp = (name)=>
  join ACME, name, 'fullchain.cer'

sslIter = (exist)->
  for i from readdirSync ACME, withFileTypes:true
    if i.isDirectory()
      {name} = i
      if name.includes('.')
        if existsSync fullchainFp name
          yield name
  return

< hostDir = =>
  exist = new Map()
  for i from sslIter()
    if i.endsWith '_ecc'
      host = i.slice(0,-4)
    else
      host = i
    exist.set host,i
  exist

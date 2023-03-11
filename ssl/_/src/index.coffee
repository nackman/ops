#!/usr/bin/env coffee

> path > join
  fs > readdirSync existsSync statSync
  @u7/read

TODAY = new Date

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

< certKey = (dir, host)=>
  key = join ACME,dir,host+'.key'
  stats = statSync(key)
  mtime = new Date(stats.mtime)

  day = (TODAY - mtime)/(86e6)
  if day >= 90
    console.error "TODO : #{dir} 证书过期了"
    return

  name = host+"_"+mtime.toISOString().slice(0,10)
  [
    name
    read fullchainFp dir
    read key
  ]


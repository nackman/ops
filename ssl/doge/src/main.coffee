#!/usr/bin/env coffee

> @u7/doge
  @u7/uridir
  dotenv
  _ > bind
  path > dirname join

DIR = dirname uridir(import.meta)
dotenv.config(path:join(DIR,'env'))

api = (url,data)=>
  doge("cdn/#{url}", data)

cdnLs = =>
  for i from (
    (await api(
      'domain/list.json'
    )).domains
  )
    i.name

do =>
  await bind(
    cdnLs

    # upload
    (host, note, cert, key)=>
      {id} = await api(
        'cert/upload.json'
        {
          note
          cert
          private:key
        }
      )
      id

    # set
    (host, cert, cert_id)=>
      await api(
        "domain/config.json?domain="+host
        {cert_id}
      )
      return

  )
  for i from (await api('cert/list.json'))
    if not i.domainCount
      await api(
        'cert/delete.json'
        id:i.id
      )

  process.exit()
  return

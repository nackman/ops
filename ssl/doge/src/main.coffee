#!/usr/bin/env coffee

> @u7/doge
  @u7/uridir
  dotenv
  path > dirname join

DIR = dirname uridir(import.meta)
dotenv.config(path:join(DIR,'env'))

for i from (
  (await doge(
    'cdn/domain/list.json'
  )).domains
)
  console.log i

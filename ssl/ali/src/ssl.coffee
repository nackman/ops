#!/usr/bin/env coffee

> @alicloud/cas20180713:_CAS
  @alicloud/cdn20180510:_CDN
  @u7/read
  @u7/default:
  path > join
  ./pager
  ./wrap
  _ > hostDir certKey

CAS = wrap _CAS, 'cas'
CDN = wrap _CDN, 'cdn'

cdnLs = =>
  for await {domainStatus,domainName} from pager(
    (pageNumber, pageSize)=>
      {
        domains: {pageData}
      } = await CDN.describeCdnUserDomainsByFunc {
        funcId: 18
        pageNumber
        pageSize
      }
      pageData
  )
    if domainStatus == 'online'
      domainName


set = (domainName, certName)=>
  console.log certName, '→', domainName
  CDN.setDomainServerCertificate {
    domainName
    certName
    serverCertificateStatus: 'on'
    certType: 'upload'
  }


upload = (host, dir, host_li)=>
  r = certKey dir, host
  if not r
    return

  [name, cert, key] = r
  try
    await CAS.createUserCertificate {
      name
      cert
      key
    }
  catch err
    console.error host,'上传证书失败 >',err.data.Message

  await Promise.all(
    host_li.map(
      (i)=>
        set(i, name)
    )
  )
  return

bind = =>
  host_dir = hostDir()
  console.log {host_dir}
  domain_dir = new Map()

  add = ()=>
    if host_dir.has name
      domain_dir.default(name,=>[]).push i
      return true
    return

  for i from await cdnLs()
    if i.startsWith('.')
      name = i.slice(1)
    else
      name = i

    if not add()
      name = name.slice(name.indexOf('.')+1)
      add()

  for [name, host_li] from domain_dir.entries()
    dir = host_dir.get name
    await upload(
      name
      dir
      host_li
    )
  return

sslRm = =>
  m = new Map
  for await i from pager(
    (currentPage, showSize)=>
      {certificateList} = await CAS.describeUserCertificateList {
        showSize
        currentPage
      }
      certificateList
  )
    m.default(i.common,=>[]).push [i.id,i.startDate]
  for [host, li] from m.entries()
    li.sort (a,b)=> if a[1]>b[1] then -1 else 1
    for [id] from li.slice(1)
      await CAS.deleteUserCertificate(certId:id)
  return

do =>
  await bind()
  await sslRm()
  process.exit()
  return


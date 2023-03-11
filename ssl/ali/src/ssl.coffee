#!/usr/bin/env coffee

> @alicloud/cas20180713:_CAS
  @alicloud/cdn20180510:_CDN
  @u7/read
  @u7/default:
  path > join
  ./pager
  ./wrap
  _ > bind

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
  await bind(
    await cdnLs()
    (name, cert, key)=>
      try
        await CAS.createUserCertificate {
          name
          cert
          key
        }
      catch err
        console.error host,'上传证书失败 >',err.data.Message
      return
    set
  )
  await sslRm()
  process.exit()
  return


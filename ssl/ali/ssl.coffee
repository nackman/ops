#!/usr/bin/env coffee

> @alicloud/cas20180713:_CAS
  @alicloud/cdn20180510:_CDN
  @iuser/read
  fs > readdirSync existsSync
  path > join
  ./pager
  ./wrap

CAS = wrap _CAS, 'cas'
CDN = wrap _CDN, 'cdn'
TODAY = new Date().toISOString()
MONTH = '_'+TODAY[..6]


iter = (exist)->
  acme = '/mnt/www/.acme.sh'
  for i from readdirSync acme, withFileTypes:true
    if i.isDirectory()
      {name} = i
      if name.includes('.') and (not exist.has name)
        dir = join acme, name
        fullchain = join dir, 'fullchain.cer'
        if existsSync fullchain
          yield {
            name
            cert:read fullchain
            key:read join dir,name+'.key'
          }
  return

sslLs = pager(
  (currentPage, showSize)=>
    {certificateList} = await CAS.describeUserCertificateList {
      showSize
      currentPage
    }
    certificateList
)

upload = (site)=>
  CAS.createUserCertificate site

cdnLs = pager(
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


bind = (domainName, certName)=>
  console.log domainName, certName
  CDN.setDomainServerCertificate {
    domainName
    certName
    serverCertificateStatus: 'on'
    certType: 'upload'
  }


sslMap = (hostLi)=>
  bindLi = (host, cert)=>
    Promise.all hostLi(host).map (d)=>
      bind d, cert

  exist = new Set()
  for await i from sslLs()
    {common,name,id,endDate} = i
    if TODAY[..9] > endDate
      await CAS.deleteUserCertificate(certId:id)
    else if name.endsWith MONTH
      if common.startsWith '*.'
        common = common[2..]
      exist.add common
      await bindLi common, name

  for i from iter(exist)
    {name} = i
    li = hostLi(name)
    if li.length
      nm = name+MONTH
      i.name = nm
      await upload i
      await bindLi name, nm
  return

do =>
  li = []
  for await {domainStatus,domainName} from cdnLs()
    if domainStatus == 'online'
      li.push domainName
  await sslMap (host)=>
    r = []
    for i from li
      if host == i or i.endsWith('.'+host)
        r.push i
    r
  return


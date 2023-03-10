#!/usr/bin/env coffee

> @alicloud/cas20180713:_CAS
  @alicloud/cdn20180510:_CDN
  @u7/read
  fs > readdirSync existsSync
  path > join
  ./pager
  ./wrap

ACME = '/mnt/www/.acme.sh'
CAS = wrap _CAS, 'cas'
CDN = wrap _CDN, 'cdn'
TODAY = new Date().toISOString()
MONTH = '_'+TODAY[..6]

fullchain_fp = (name)=>
  join ACME, name, 'fullchain.cer'

sslIter = (exist)->
  for i from readdirSync ACME, withFileTypes:true
    if i.isDirectory()
      {name} = i
      if name.includes('.')
        if existsSync fullchain_fp name
          yield name
        # console.log '>>name',name,exist
        # if not exist.has name
        #   dir = join acme, name
        #   if existsSync fullchain
        #     yield {
        #       name
        #       cert:read fullchain
        #       key:read join dir,name+'.key'
        #     }
  return

hostDir = =>
  exist = new Map()
  for i from sslIter()
    if i.endsWith '_ecc'
      host = i.slice(0,-4)
    else
      host = i
    exist.set host,i
  exist
#
# sslLs = pager(
#   (currentPage, showSize)=>
#     {certificateList} = await CAS.describeUserCertificateList {
#       showSize
#       currentPage
#     }
#     certificateList
# )
#
# upload = (site)=>
#   CAS.createUserCertificate site
#
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

#
# bind = (domainName, certName)=>
#   console.log domainName, certName
#   CDN.setDomainServerCertificate {
#     domainName
#     certName
#     serverCertificateStatus: 'on'
#     certType: 'upload'
#   }
#
#
# sslMap = (hostLi)=>
#   bindLi = (host, cert)=>
#     Promise.all hostLi(host).map (d)=>
#       bind d, cert
#
#   exist = new Set()
#   for await i from sslLs()
#     {common,name,id,endDate} = i
#     if TODAY[..9] > endDate
#       await CAS.deleteUserCertificate(certId:id)
#     else if name.endsWith MONTH
#       if common.startsWith '*.'
#         common = common[2..]
#       exist.add common
#       await bindLi common, name
#
#   for i from iter(exist)
#     {name} = i
#     li = hostLi(name)
#     if li.length
#       nm = name+MONTH
#       i.name = nm
#       console.log {i,name,nm}
#       await upload i
#       await bindLi name, nm
#   return

do =>
  console.log hostDir()

  console.log await cdnLs()

  # await sslMap (host)=>
  #   r = []
  #   for i from li
  #     if host == i or i.endsWith('.'+host)
  #       r.push i
  #   r
  return


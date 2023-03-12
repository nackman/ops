MAIL=i@user.tax

# https://github.com/acmesh-official/acme.sh/wiki/dnsapi

# DNS=dp

# export DP_Id=
# export DP_Key=

# 更复杂的情况，不同域名用不同的DNS

# DNSPOD=(user.tax usr.tax)
#
# for t in ${DNSPOD[@]}; do
#   if [[ $1 == $t || $1 == *.$t ]]; then
#     set +x
#     export DP_Id=
#     export DP_Key=
#     set -x
#     DNS=dp
#     break
#   fi
# done
#
# if [ -z "$DNS" ]; then
#
# DNS=ali
#
# set +x
# export Ali_Key=
# export Ali_Secret=
# set -x
#
# fi

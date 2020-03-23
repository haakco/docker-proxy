#!/bin/sh
# Make sure our cache is setup
mkdir -p /cache/squid3
mkdir -p /cache/apt-cacher-ng
mkdir -p /cache/logs/squid3
mkdir -p /cache/logs/apt-cacher-ng
mkdir -p /cache/logs/supervisor
mkdir -p /cache/apt-cacher-ng/_import

chown -R squid:squid /cache /squid_config

#[ -e /cache/squid3/swap.state ] || /usr/sbin/squid -f /squid_config/squid.conf -z 2>/dev/null

IFS=","

SQUID_ALLOWED_NETWORKS=
for ALLOWED_NETWORK in ${ALLOWED_NETWORKS}; do
    SQUID_ALLOWED_NETWORKS="${SQUID_ALLOWED_NETWORKS}acl localnet src ${ALLOWED_NETWORK}
"
done

SQUID_EXTRA_HTTPS_PORTS=
for EXTRA_HTTPS_PORT in ${EXTRA_HTTPS_PORTS}; do
    SQUID_EXTRA_HTTPS_PORTS="acl SSL_ports port ${EXTRA_HTTPS_PORT}
"
done

PROXY_ENABLED=""

if [ "${ENABLE_PROXY}" = "TRUE" ] ; then
  PROXY_ENABLED=${PROXY_ENABLED}"http_port 3128\n";
fi

if [ "${ENABLE_ACCEL}" = "TRUE" ] ; then
  PROXY_ENABLED=${PROXY_ENABLED}"http_port 3142 accel\n";
fi

if [ "${ENABLE_INTERCEPT}" = "TRUE" ] ; then
  PROXY_ENABLED=${PROXY_ENABLED}"http_port 3129 intercept\n";
fi

if [ -z "${PARENT_PROXY}" ] || [ ${PARENT_PROXY} == '""' ] ; then
    ACNG_PARENT_PROXY=
    SQUID_PARENT_PROXY=
else
    ACNG_PARENT_PROXY="Proxy: ${PARENT_PROXY}"

    SQUID_PARENT_PROXY=`echo ${PARENT_PROXY} | sed -E \
    -e 's/(http(|s)):\/\/((.+)\:(.+)@|)(.+)\:([0-9]+)/cache_peer \6  parent \7 0 default 888\4:\5888 999\2999 name=parent/' \
     -e 's/999999//' \
     -e 's/999s999/ssl/' \
     -e 's/888:888//' \
     -e 's/888(.+)888/login=\1/'`

SQUID_PARENT_PROXY="${SQUID_PARENT_PROXY}

cache_peer_access parent deny aptget
cache_peer_access parent deny deburl
cache_peer_access parent deny to_ubuntu_mirrors
cache_peer_access parent allow all

never_direct allow all
    "
fi

perl -pe "s|\Q#SQUID_ALLOWED_NETWORKS\E|$SQUID_ALLOWED_NETWORKS|g" /squid_config/squid.tmpl.conf > /squid_config/squid.conf
perl -pe "s|\Q#SQUID_EXTRA_HTTPS_PORTS\E|$SQUID_EXTRA_HTTPS_PORTS|g" -i /squid_config/squid.conf
perl -pe "s|\Q#SQUID_PARENT_PROXY\E|$SQUID_PARENT_PROXY|g" -i /squid_config/squid.conf
perl -pe "s|\Q#PROXY_ENABLED\E|$PROXY_ENABLED|g" -i /squid_config/squid.conf

ln -sf /cache/logs/squid3 /var/log/squid

/usr/sbin/squid -f /squid_config/squid.conf -z
sleep 5
/usr/sbin/squid -N -f /squid_config/squid.conf

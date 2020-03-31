#!/bin/sh
#
# DNS support routines for assigning DNS entries for several devices. This
# module adds DNS support for scripts.
#

RESOLV_FILE="/tmp/resolv.conf"
DNS_TMP="/tmp/dns"

dns_reset()
{
    local iface="$1"; shift
    local resolv="${DNS_TMP}/${iface}.resolv"

    mkdir -p "${DNS_TMP}"

    # Touch temporary resolv file
    echo -n > "${resolv}.$$"
}

dns_add()
{
    local iface="$1" ; shift
    local resolv="${DNS_TMP}/${iface}.resolv"

    echo "$@" >> "${resolv}.$$"
}

dns_apply()
{
    local iface="$1" ; shift
    local resolv="${DNS_TMP}/${iface}.resolv"

    [ -e "${resolv}.$$" ] && {
        mv -f "${resolv}.$$" "${resolv}"
    }

    find "${DNS_TMP}" -name '*.resolv' -exec cat {} \; > "${RESOLV_FILE}.$$"
    mv "${RESOLV_FILE}.$$" "${RESOLV_FILE}"
}

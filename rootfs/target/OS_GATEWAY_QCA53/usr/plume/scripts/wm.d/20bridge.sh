#!/bin/sh
#
# Put home interfaces into br-home
#

ifname=$1

case "$ifname" in
    *home-*)
        ovs-vsctl add-port br-home $ifname
        ;;
esac

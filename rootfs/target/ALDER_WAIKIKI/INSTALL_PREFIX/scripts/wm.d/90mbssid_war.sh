#!/bin/sh
# {# jinja-parse #}

# WAR for various client issues related to MBSSID.
# We need to make sure that non hidden vap is the tx-vap on 6G radio
# since this configuration helps with connectivity and stability
# of various 6G capable clients.
INSTALL_PREFIX={{INSTALL_PREFIX}}
ovsh=${INSTALL_PREFIX}/tools/ovsh
in_vap=$1

# Compile list of 6GHz ap
for vap in `$ovsh s Wifi_VIF_Config -w mode==ap if_name -r`; do
    $ovsh s Wifi_Radio_Config vif_configs freq_band  -r | grep -F `$ovsh s Wifi_VIF_Config -w if_name==$vap  _uuid -U -r` | cut -d " "  -f 1 | grep -qv 6G && continue
    ap_6g_list="$ap_6g_list $vap"
done
logger -t $(basename $0) "6GHz ap list: $ap_6g_list"

# Check if current vap is in 6GHz AP list
echo $ap_6g_list | grep -qv $in_vap && exit 0

# Check current vap is hidden or not. If currently configuring vap is hidden exit.
$ovsh s Wifi_VIF_Config -w if_name==$in_vap ssid_broadcast -r | grep -q disabled && exit 0

# Find current tx-vap and check if ssid is hidden or not. If current tx-vap is already non hidden nothing is left to do.
for vap in $ap_6g_list; do
    cfg80211tool $vap g_mbss_tx_vdev | grep -q 'g_mbss_tx_vdev:1' && break
done
$ovsh s Wifi_VIF_Config -w if_name==$vap ssid_broadcast -r | grep -q enabled && exit 0

# Reorder VAPs, need to be in down state
for vap in $ap_6g_list; do
    logger -t $(basename $0) "$vap: down"
    ifconfig $vap down
done

# Select tx-vap, go back to up state
logger -t $(basename $0) "$in_vap: set as tx-vap"
cfg80211tool $in_vap mbss_tx_vdev 1
for vap in $ap_6g_list; do
    logger -t $(basename $0) "$vap: up"
    ifconfig $vap up
done

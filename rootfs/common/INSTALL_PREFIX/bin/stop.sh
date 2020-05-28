#!/bin/sh
# {# jinja-parse #}

gre_filter()
{
    awk '
    /[0-9]+: ([^:])+:/ {
        IF=substr($2, 1, index($2, "@") - 1)
    }

    / +gretap remote/ {
        print IF
    }'
}

gre_purge()
{
    ip -d link show | gre_filter | while read IF
    do
        echo "Removing GRE tunnel: $IF"
        ip link del "$IF"
    done
}

# NM/WM/SM can interact with wifi driver therefore
# wpa_supplicant and hostap must be killed afterwards to
# avoid races and unexpected driver sequences.
#
# logd stores logs to tmpfs (slow flash). These
# logs are picked up by FM and copied over to
# flash. If FM was stopped here and system crashed
# during teardown then logs would had been lost.
# Therefore FM is stopped at the very end to
# collect as much logs as possible prior to crash.
echo "killing managers"
killall -s SIGKILL dm cm nm wm lm sm bm um om qm fsm fcm

# From this point on CM is dead and no one is kicking
# watchdog.  There's less than 60s to complete everything
# down below before device throws a panic and reboots.

# Kindly ask wpa_s/hostap to terminate. Driver gets angry if
# you're too bold.
for i in bhaul-sta-24 bhaul-sta-50 bhaul-sta-l50 bhaul-sta-u50
do
    sockpath=/var/run/wpa_supplicant-$(cat /sys/class/net/$i/parent)
    test -e $sockpath/$i || continue
    timeout -t 3 wpa_cli -p $sockpath -i $i disc
    timeout -t 10 sh -x <<-.
            while ! wpa_cli -p $sockpath -i $i stat | egrep 'wpa_state=(DISCONNECTED|INACTIVE|INTERFACE_DISABLED)'
            do
                sleep 1
            done
.
done
killall -s SIGTERM hostapd wpa_supplicant
timeout -t 10 sh -x <<-.
    while pidof hostapd || pidof wpa_supplicant
    do
        sleep 1
    done
.
killall -s SIGKILL hostapd wpa_supplicant

# Stop miniupnd
/etc/init.d/miniupnpd stop
echo "miniupnpd stop"

# Purge all GRE tunnels
gre_purge

# Stop cloud connection
echo "Removing manager"
ovs-vsctl del-manager

# Destroy all bridges
#this is to remove bridge interfaces from system
for BRIDGE in $(ovs-vsctl list-br); do ovs-vsctl del-br $BRIDGE; echo "Removing $BRIDGE"; done

# Stop openvswitch
/etc/init.d/openvswitch stop
echo "openvswitch stop"

# Destroy all wifi interfaces
{% if CONFIG_PLATFORM_QCA_QSDK110 %}
for WIFI in $(iwconfig 2>&1 | grep ESSID | cut -d ' ' -f 1); do echo "destroying $WIFI"; cfg80211tool $WIFI dbgLVL 0xf5ffffff; ifconfig $WIFI down; wlanconfig $WIFI destroy; done
{% else %}
for WIFI in $(iwconfig 2>&1 | grep ESSID | cut -d ' ' -f 1); do echo "destroying $WIFI"; iwpriv $WIFI dbgLVL 0xf5ffffff; ifconfig $WIFI down; wlanconfig $WIFI destroy; done
{% endif %}

# Stop DNS service
for PID in $(pgrep dnsmasq); do echo "kill dns: $(cat /proc/$PID/cmdline)"; kill $PID; done

# Stop all DHCP clients
killall udhcpc

# Remove existing DHCP leases
rm /tmp/dhcp.leases

#remove old wpa_ctrl sockets
rm -f /tmp/wpa_ctrl_*

# Kill PPP connections
killall pppd

# Reset DNS files
rm -rf /tmp/dns

/etc/init.d/lldpd stop

timeout -t 3 sh -x <<-.
    killall -KILL fm
    while pidof fm
    do
        sleep 1
    done
.

sleep 2

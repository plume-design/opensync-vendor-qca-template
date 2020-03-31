#!/bin/sh
# {# jinja-parse #}
INSTALL_PREFIX={{INSTALL_PREFIX}}

wait_insmod()
{
    # Wait until wifi0, wifi1 and wifi2 interfaces show up
    RETRY=90
    while [ ${RETRY} -gt 0 ]
    do
        [ -e /sys/class/net/wifi0 -a -e /sys/class/net/wifi1 -a -e /sys/class/net/wifi2 ] && return 0
        sleep 1
        RETRY=$((RETRY - 1 ))
    done

    # Not sure what to do exactly here,
    logger -t opensync -p daemon.crit "ERROR: Wifi modules failed to load. Unable to start OpenSync managers."
    exit 1
}

qca_wpa_hapd_stop()
{
    killall hostapd wpa_supplicant
    sleep 1
    rm -rf /var/run/hostapd*
    rm -rf /var/run/wpa_supplicant*
}

qca_wpa_hapd_start()
{
    /etc/init.d/qca-hostapd boot
    /etc/init.d/qca-wpa-supplicant boot
}

wait_insmod
qca_wpa_hapd_stop
qca_wpa_hapd_start

# Create run dir for dnsmasq
mkdir -p /var/run/dnsmasq

# Start openvswitch
echo -n 'Starting Open vSwitch ...'
/etc/init.d/openvswitch start

# Add default internal bridge
sleep 1

# Add offset to a MAC address
mac_set_local_bit()
{
    local MAC="$1"

    # ${MAC%%:*} - first digit in MAC address
    # ${MAC#*:} - MAC without first digit
    printf "%02X:%s" $(( 0x${MAC%%:*} | 0x2 )) "${MAC#*:}"
}

# Get the MAC address of an interface
mac_get()
{
    ifconfig "$1" | grep -o -E '([A-F0-9]{2}:){5}[A-F0-9]{2}'
}

##
# Configure bridges
#
MAC_ETH0=$(mac_get eth0)
# Set the local bit on eth0
MAC_ETH1=$(mac_set_local_bit ${MAC_ETH0})

echo "Adding br-wan with MAC address $MAC_ETH0"
ovs-vsctl add-br br-wan
ovs-vsctl set bridge br-wan other-config:hwaddr="$MAC_ETH0"
ovs-vsctl set int br-wan mtu_request=1500

echo "Adding br-home with MAC address $MAC_ETH1"
ovs-vsctl add-br br-home
ovs-vsctl set bridge br-home other-config:hwaddr="$MAC_ETH1"

# This is GW image specific
echo "Adding eth0 to br-wan"
ovs-vsctl add-port br-wan eth0

echo "Enabling LAN interface eth1"
ifconfig eth1 up

lldpctl | logger

##
# Install and configure SSL certs
#
mkdir -p /var/certs
cp ${INSTALL_PREFIX}/certs/* /var/certs/

# Update Open_vSwitch table: Must be done here instead of pre-populated
# because row doesn't exist until openvswitch is started
ovsdb-client transact '
["Open_vSwitch", {
    "op": "insert",
    "table": "SSL",
    "row": {
        "ca_cert": "/var/certs/ca.pem",
        "certificate": "/var/certs/client.pem",
        "private_key": "/var/certs/client_dec.key"
    },
    "uuid-name": "ssl_id"
}, {
    "op": "update",
    "table": "Open_vSwitch",
    "where": [],
    "row": {
        "ssl": ["set", [["named-uuid", "ssl_id"]]]
    }
}]'

# Change interface stats update interval to 1 hour
ovsdb-client transact '
["Open_vSwitch", {
    "op": "update",
    "table": "Open_vSwitch",
    "where": [],
    "row": {
        "other_config": ["map", [["stats-update-interval", "3600000"] ]]
    }
}]'

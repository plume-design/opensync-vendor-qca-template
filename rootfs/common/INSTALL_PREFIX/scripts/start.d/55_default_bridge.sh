#!/bin/sh
# {# jinja-parse #}

# Add default internal bridge

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
MAC_ETH1=$(mac_get eth1)

echo "Adding br-home with MAC address $MAC_ETH1"
ovs-vsctl add-br br-home
ovs-vsctl set bridge br-home other-config:hwaddr="$MAC_ETH1"

echo "Enabling LAN interface eth1"
ifconfig eth1 up



gen_eth_iface()
{
    IFNAME=$1
cat << EOF
    {
        "op":"insert",
        "table":"Wifi_Inet_Config",
        "row":
        {
            "if_name": "$IFNAME",
            "ip_assign_scheme": "none",
            "if_type": "eth",
            "enabled": true,
            "network": true,
            "mtu": 1500,
            "NAT": false
        }
    }
EOF

}

IFACES="$(gen_eth_iface eth2),$(gen_eth_iface eth3),$(gen_eth_iface eth4)"

cat << EOF
[
    "Open_vSwitch",
    $IFACES
]

EOF

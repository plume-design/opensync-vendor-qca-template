ip_assign_scheme="dhcp"
mtu=1600

cat << EOF
[
    "Open_vSwitch",
    {
        "op":"insert",
        "table":"Wifi_Inet_Config",
        "row": {
            "if_name": "bhaul-sta-24",
            "ip_assign_scheme": "$ip_assign_scheme",
            "mtu": $mtu,
            "if_type": "vif",
            "enabled" : true,
            "network" : false,
            "NAT": false
        }
    },
    {
        "op":"insert",
        "table":"Wifi_Inet_Config",
        "row": {
            "if_name": "bhaul-sta-l50",
            "ip_assign_scheme": "$ip_assign_scheme",
            "mtu": $mtu,
            "if_type": "vif",
            "enabled" : true,
            "network" : false,
            "NAT": false
        }
    },
    {
        "op":"insert",
        "table":"Wifi_Inet_Config",
        "row": {
            "if_name": "bhaul-sta-u50",
            "ip_assign_scheme": "$ip_assign_scheme",
            "mtu": $mtu,
            "if_type": "vif",
            "enabled" : true,
            "network" : false,
            "NAT": false
        }

    }
]
EOF

# WDS by default

if [ "$BUILD_BHAUL_WDS" = "y" ];
then
    ip_assign_scheme="none"
    mtu=1500
else
    ip_assign_scheme="dhcp"
    mtu=1600
fi

case "$TARGET" in
    AKRONITE)
        mtu=1600
    ;;
    *)
        mtu=1552
    ;;
esac

case "$TARGET" in
    AKRONITE)

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
                    "if_name": "bhaul-sta-50",
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
        ;;
    *)
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
                    "if_name": "bhaul-sta-50",
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
        ;;
esac

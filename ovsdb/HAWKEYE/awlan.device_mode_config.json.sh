cat << EOF
[
    "Open_vSwitch",
    {
        "op":"update",
        "table":"AWLAN_Node",
        "where":[],
        "row": {
        "device_mode" : "cloud"
        }
    }
]

EOF

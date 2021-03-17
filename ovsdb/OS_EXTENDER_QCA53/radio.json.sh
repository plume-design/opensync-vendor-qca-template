##
# Pre-populate WiFi related OVSDB tables
#

generate_onboarding_ssid()
{
    cat << EOF
        "$BACKHAUL_SSID"
EOF
}

generate_onboarding_psk()
{
    cat << EOF
        ["map",
            [
                ["encryption","WPA-PSK"],
                ["key", "$BACKHAUL_PASS"]
            ]
       ]
EOF
}

cat << EOF
[
    "Open_vSwitch",
    {
        "op": "insert",
        "table": "Wifi_VIF_Config",
        "row": {
            "enabled": true,
            "vif_dbg_lvl": 0,
            "if_name": "bhaul-sta-24",
            "bridge": "",
            "mode": "sta",
            "wds": false,
            "vif_radio_idx": 0,
            "ssid": $(generate_onboarding_ssid),
            "security": $(generate_onboarding_psk)
        },
        "uuid-name": "id0"
    },
    {
        "op": "insert",
        "table": "Wifi_VIF_Config",
        "row": {
            "enabled": true,
            "vif_dbg_lvl": 0,
            "if_name": "bhaul-sta-l50",
            "bridge": "",
            "mode": "sta",
            "wds": false,
            "vif_radio_idx": 0,
            "ssid": $(generate_onboarding_ssid),
            "security": $(generate_onboarding_psk)
        },
        "uuid-name": "id1"
    },
    {
        "op": "insert",
        "table": "Wifi_VIF_Config",
        "row": {
            "enabled": true,
            "vif_dbg_lvl": 0,
            "if_name": "bhaul-sta-u50",
            "bridge": "",
            "mode": "sta",
            "wds": false,
            "vif_radio_idx": 0,
            "ssid": $(generate_onboarding_ssid),
            "security": $(generate_onboarding_psk)
        },
        "uuid-name": "id2"
    },
    {
        "op": "insert",
        "table": "Wifi_Radio_Config",
        "row": {
            "enabled": true,
            "if_name": "wifi0",
            "freq_band": "2.4G",
            "channel_mode": "cloud",
            "channel_sync": 0,
            "hw_type": "qca4019",
            "hw_config": ["map",[]],
            "ht_mode": "HT40",
            "hw_mode": "11n",
            "vif_configs": ["set", [ ["named-uuid", "id0"] ] ]
        }
    },
    {
        "op": "insert",
        "table": "Wifi_Radio_Config",
        "row": {
            "enabled": true,
            "if_name": "wifi1",
            "freq_band": "5GL",
            "channel_mode": "cloud",
            "channel_sync": 0,
            "hw_type": "qca4019",
            "hw_config": ["map",[]],
            "ht_mode": "HT80",
            "hw_mode": "11ac",
            "vif_configs": ["set", [ ["named-uuid", "id1"] ] ]
        }
    },
    {
        "op": "insert",
        "table": "Wifi_Radio_Config",
        "row": {
            "enabled": true,
            "if_name": "wifi2",
            "freq_band": "5GU",
            "channel_mode": "cloud",
            "channel_sync": 0,
            "hw_type": "qca9984",
            "hw_config": ["map",[]],
            "ht_mode": "HT80",
            "hw_mode": "11ac",
            "vif_configs": ["set", [ ["named-uuid", "id2"] ] ]
        }
    }
]
EOF

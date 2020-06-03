BACKHAUL_SSID=$OS_ONBOARDING_SSID
BACKHAUL_PASS=$OS_ONBOARDING_PSK

gen_json_psk2()
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

gen_json_eaptls()
{
    cat << EOF

        ["map",
            [
                ["encryption","WPA-EAP"],
                ["eap_ca_cert","ca.pem"],
                ["eap_client_cert","client.pem"],
                ["eap_private_key","client_dec.key"],
                ["eap_cert_path","/var/certs/"],
                ["eap_identity","pnode"]
            ]
        ]
EOF
}

gen_qca4074_config()
{
    cat << EOF
        ["map",
            [
                ["dfs_usenol", "1"],
                ["dfs_ignorecac", "0"],
                ["dfs_enable", "1"]
            ]
        ]
EOF
}

gen_json_creds()
{
    if [ -z "$MULTI_BACKHAUL_CREDS" ]; then
        return
    fi
    echo -n "$MULTI_BACKHAUL_CREDS" | xargs -d';' -n2 sh -c '
        ssid="$0"
        passwd="$1"

sec=`cat << EOF
        ["map",
            [
                ["encryption","WPA-PSK"],
                ["key", "$passwd"]
            ]
        ]
EOF`

cat << EOF
    {
        "op": "insert",
        "table": "Wifi_Credential_Config",
        "row": {
            "ssid": "$ssid",
            "security":
$sec,
            "onboard_type": "gre"
        },
        "uuid-name": "Wifi_Multi_Cred_`uuidgen | tr -d "-"`"
    },
EOF
'
}

gen_named_uuid()
{
    if [ -z "$1" ]; then
        return
    fi
    res=$(echo $1 | grep -o '"uuid-name": "[a-zA-Z0-9_]*"' | sed 's/"uuid-name":/["named-uuid",/' | sed ':a;N;$!ba;s/\n/],/g')

cat << EOF
        "credential_configs":["set", [
            $res] ] ],
EOF
}

# PSK2 now set by default
if [ -z "$CONFIG_OPENSYNC_ONBOARD_PSK" ] || [ "$CONFIG_OPENSYNC_ONBOARD_PSK2" = "y" ];
then
    gen_security="gen_json_psk2"
else
    gen_security="gen_json_eaptls"
fi

creds=$(gen_json_creds)
creds_configs=$(gen_named_uuid "$creds")

cat << EOF
[
    "Open_vSwitch",
$creds
    {
        "op": "insert",
        "table": "Wifi_VIF_Config",
        "row": {
            "enabled": true,
            "vif_dbg_lvl": 0,
            "if_name": "bhaul-sta-24",
            "mode": "sta",
            "vif_radio_idx": 0,
            "ssid": "$BACKHAUL_SSID",
$creds_configs
            "security": $($gen_security)
        },
        "uuid-name": "id0"
    },
    {
        "op": "insert",
        "table": "Wifi_VIF_Config",
        "row": {
            "enabled": true,
            "vif_dbg_lvl": 0,
            "if_name": "bhaul-sta-50",
            "mode": "sta",
            "vif_radio_idx": 0,
            "ssid": "$BACKHAUL_SSID",
$creds_configs
            "security": $($gen_security)
        },
        "uuid-name": "id1"
    },
    {
        "op": "insert",
        "table": "Wifi_Radio_Config",
        "row": {
            "enabled": true,
            "if_name": "wifi1",
            "freq_band": "5G",
            "channel_mode": "cloud",
            "channel_sync": 0,
            "hw_type": "qca4074",
            "hw_config": $(gen_qca4074_config),
            "ht_mode": "HT80",
            "hw_mode": "11ac",
            "tx_chainmask":3,
            "vif_configs": ["set", [
                ["named-uuid", "id1"] ] ]
        }
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
            "hw_type": "qca4074",
            "ht_mode": "HT40",
            "hw_mode": "11n",
            "tx_chainmask":3,
            "vif_configs": ["set", [
                ["named-uuid", "id0"] ] ]
        }
    },
    {
        "op": "insert",
        "table": "Wifi_Radio_Config",
        "row": {
            "enabled": true,
            "if_name": "wifi2",
            "freq_band": "5G",
            "channel_mode": "cloud",
            "channel_sync": 0,
            "hw_type": "qca4074",
            "hw_config": $(gen_qca4074_config),
            "ht_mode": "HT80",
            "hw_mode": "11ac",
            "tx_chainmask":3,
            "vif_configs": ["set", [
                ["named-uuid", "id2"] ] ]
        }
    }
]
EOF

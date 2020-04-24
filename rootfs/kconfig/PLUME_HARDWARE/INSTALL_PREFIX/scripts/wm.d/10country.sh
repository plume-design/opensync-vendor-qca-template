#!/bin/sh
# {# jinja-parse #}
#
# Re-set country since it might get unset by QCA driver during STA
# interface destroy operation.
#

ifname=$1
phyname=$(cat /sys/devices/virtual/net/${ifname}/parent)
country=SI

{% if CONFIG_PLATFORM_QCA_QSDK110 %}
cur_country=`cfg80211tool ${phyname} getCountry | cut -d":" -f2`
if [ "$cur_country" = "$country " ]; then
    echo "Country code already set"
else
    cfg80211tool ${phyname} setCountry ${country}
fi
{% else %}
iwpriv ${phyname} setCountry ${country}
{% endif %}

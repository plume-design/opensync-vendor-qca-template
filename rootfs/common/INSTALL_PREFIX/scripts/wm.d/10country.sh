#!/bin/sh
#
# Re-set country since it might get unset by QCA driver during STA
# interface destroy operation.
#

ifname=$1
phyname=$(cat /sys/devices/virtual/net/${ifname}/parent)
country=SI

iwpriv ${phyname} setCountry ${country}

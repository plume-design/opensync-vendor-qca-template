#!/bin/sh
# {# jinja-parse #}
INSTALL_PREFIX={{INSTALL_PREFIX}}

[ -z "$1" ] && echo "Error: should be run by udhcpc" && exit 1

OPTS_FILE=/var/run/udhcpc_$interface.opts

set_classless_routes()
{
    local max=128
    local type
    while [ -n "$1" -a -n "$2" -a $max -gt 0 ]; do
        [ ${1##*/} -eq 32 ] && type=host || type=net
        echo "udhcpc: adding route for $type $1 via $2"
        route add -$type "$1" gw "$2" dev "$interface"
        max=$(($max-1))
        shift 2
    done
}

print_opts()
{
    [ -n "$router" ]    && echo "gateway=$router"
    [ -n "$timesrv" ]   && echo "timesrv=$timesrv"
    [ -n "$namesrv" ]   && echo "namesrv=$namesrv"
    [ -n "$dns" ]       && echo "dns=$dns"
    [ -n "$logsrv" ]    && echo "logsrv=$logsrv"
    [ -n "$cookiesrv" ] && echo "cookiesrv=$cookiesrv"
    [ -n "$lprsrv" ]    && echo "lprsrv=$lprsrv"
    [ -n "$hostname" ]  && echo "hostname=$hostname"
    [ -n "$domain" ]    && echo "domain=$domain"
    [ -n "$swapsrv" ]   && echo "swapsrv=$swapsrv"
    [ -n "$ntpsrv" ]    && echo "ntpsrv=$ntpsrv"
    [ -n "$lease" ]     && echo "lease=$lease"
    # vendorspec may contain all sorts of binary characters, convert it to base64
    [ -n "$vendorspec" ] && echo "vendorspec=$(echo $vendorspec | base64)"
}

setup_interface()
{
    echo "udhcpc: ifconfig $interface $ip netmask ${subnet:-255.255.255.0} broadcast ${broadcast:-+}"
    ifconfig $interface $ip netmask ${subnet:-255.255.255.0} broadcast ${broadcast:-+}

    [ -n "$router" ] && [ "$router" != "0.0.0.0" ] && [ "$router" != "255.255.255.255" ] && {
        echo "udhcpc: setting default routers: $router"

        local valid_gw=""
        for i in $router ; do
            route add default gw $i dev $interface
            valid_gw="${valid_gw:+$valid_gw|}$i"
        done

        eval $(route -n | awk '
            /^0.0.0.0\W{9}('$valid_gw')\W/ {next}
            /^0.0.0.0/ {print "route del -net "$1" gw "$2";"}
        ')
    }
    # CIDR STATIC ROUTES (rfc3442)
    [ -n "$staticroutes" ] && set_classless_routes $staticroutes
    [ -n "$msstaticroutes" ] && set_classless_routes $msstaticroutes

    #
    # Save the options list
    #
    print_opts > $OPTS_FILE
}

applied=
case "$1" in
    deconfig)
        ifconfig "$interface" 0.0.0.0
        rm -f "$OPTS_FILE"
        ;;
    renew)
        setup_interface update
        ;;
    bound)
        setup_interface ifup
        ;;
esac

# custom scripts
for x in ${INSTALL_PREFIX}/scripts/udhcpc.d/[0-9]*
do
    [ ! -x "$x" ] && continue
    # Execute custom scripts
    "$x" "$1"
done

# user rules
[ -f /etc/udhcpc.user ] && . /etc/udhcpc.user

exit 0

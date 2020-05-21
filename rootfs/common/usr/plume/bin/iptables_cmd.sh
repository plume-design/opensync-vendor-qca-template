#!/bin/sh -e
#
# Firewall configuration helper
#
# Note that boot configuration is very permissive so it should be tightened
# for production devices.
#

UPNP_BIN="/usr/sbin/miniupnpd"
UPNP_DIR="/tmp/miniupnpd"

log()
{
    echo "$@"
}

to_syslog()
{
    logger -s -t firewall 2>&1
}

iptables_boot()
{
    log "Setting default IPv4 policies"

    # Set default policies
    iptables -w -P INPUT ACCEPT
    iptables -w -P FORWARD ACCEPT
    iptables -w -P OUTPUT ACCEPT

    # Flush all other rules
    iptables -w -F
    iptables -w -X
    iptables -w -t nat -F
    iptables -w -t nat -X
    iptables -w -t mangle -F
    iptables -w -t mangle -X

    log "Installing permanent rules"
    iptables -w -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -w -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -w -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

    # Always enable the local interface
    iptables -w -A INPUT -i lo -j ACCEPT
    log "Enabling eth0.4 unconditionally"
    iptables -w -A INPUT -i eth0.4 -j ACCEPT

    log "Enabling ICMP protocol on all interfaces"
    iptables -w -A INPUT -p icmp -j ACCEPT

    log "Adding NM wavering chains"

    # NM allow input on interfaces
    iptables -w -t filter -N NM_INPUT
    iptables -w -t filter -A INPUT -j NM_INPUT

    # NM enable NAT on interfaces
    iptables -w -t nat -N NM_NAT
    iptables -w -t nat -A POSTROUTING -j NM_NAT
    iptables -w -t nat -N NM_PORT_FORWARD
    iptables -w -t nat -A PREROUTING -j NM_PORT_FORWARD

    log "Adding MINIUPNPD chains"
    iptables -w -t filter -N MINIUPNPD
    iptables -w -t nat -N MINIUPNPD
}

ip6tables_boot()
{
    log "Setting default IPv6 policies"
    # Set default policies
    ip6tables -P INPUT DROP
    ip6tables -P FORWARD DROP
    ip6tables -P OUTPUT ACCEPT

    # Flush all other rules
    ip6tables -F
    ip6tables -X
    ip6tables -t mangle -F
    ip6tables -t mangle -X

    log "Installing permanent rules"
    ip6tables -A INPUT   -m state --state RELATED,ESTABLISHED -j ACCEPT
    ip6tables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    ip6tables -A OUTPUT  -m state --state RELATED,ESTABLISHED -j ACCEPT

    # Always enable the local interface
    ip6tables -A INPUT -i lo -j ACCEPT
    log "Enabling eth0.4 unconditionally"
    ip6tables -A INPUT -i eth0.4 -j ACCEPT

    log "Enabling ICMPv6 protocol on all interfaces"
    ip6tables -A INPUT -p icmpv6 -j ACCEPT

    log "Enabling DHCPv6 protocol on all interfaces"
    ip6tables -A INPUT -m state --state NEW -m udp -p udp --dport 546 -d fe80::/64 -j ACCEPT

    log "Adding NM wavering chains"

    # NM allow input on interfaces
    ip6tables -t filter -N NM_INPUT
    ip6tables -t filter -A INPUT -j NM_INPUT

    # NM forwarding chain
    ip6tables -t filter -N NM_FORWARD
    ip6tables -t filter -A FORWARD -j NM_FORWARD

    # no NAT on IPv6

    log "Adding MINIUPNPD chains"
    ip6tables -t filter -N MINIUPNPD
}

#
# - Clear all wavering rules
# - Stop the upnp deamon and flush its rules
#
iptables_flush()
{
    # Flush out NM rules
    log "Flushing NM rules: NM_NAT NM_PORT_FORWARD NM_INPUT"
    iptables  -t nat    -F NM_NAT
    iptables  -t nat    -F NM_PORT_FORWARD
    iptables  -t filter -F NM_INPUT

    ip6tables -t filter -F NM_INPUT
    ip6tables -t filter -F NM_FORWARD

    # Stop miniupnpd daemon
    upnpd_stop

    log "Flushing MINIUPNPD rules"
    iptables  -t filter -F MINIUPNPD
    ip6tables -t filter -F MINIUPNPD
    iptables  -t nat    -F MINIUPNPD
}

#
# Flag the interface as being on LAN -- we should enable all ports in such case to allow
# DHCP and SSH to go through
#
iptables_lan()
{
    local ifname="$1"   # LAN interface

    [ -z "$ifname" ] && {
        log "lan command requires an interface as argument"
        exit 1
    }

    echo "Enabling IPv4 LAN access on $ifname"

    # Accept all incoming packets
    iptables -A NM_INPUT -i "$ifname" -j ACCEPT
}

ip6tables_lan()
{
    local ifname="$1"   # LAN interface

    [ -z "$ifname" ] && {
        log "lan command requires an interface as argument"
        exit 1
    }

    echo "Enabling IPv6 LAN access on $ifname"

    # Accept all incoming packets
    ip6tables -A NM_INPUT -i "$ifname" -j ACCEPT
    # Accept forwarded packets from local interfaces
    ip6tables -A NM_FORWARD -i "$ifname" -j ACCEPT
}

#
# Enable NAT on specific interface -- this is only for outgoing traffic
#
iptables_nat()
{
    local ifname="$1"   # WAN interface

    [ -z "$ifname" ] && {
        log "nat command requires an interface as argument"
        exit 1
    }

    echo "Enabling NAT on $ifname"

    iptables -t nat -A NM_NAT -o "$ifname" -j MASQUERADE

    # Plant the miniupnpd rule for port forwarding via upnp
    iptables -t nat -A NM_PORT_FORWARD -i "$ifname" -j MINIUPNPD
}

iptables_forward()
{
    local proto="$1"    # protocol "tcp" or "udp"
    local ifname="$2"   # Interface to perform port-forwarding on
    local sport="$3"    # local port (from the pods perspective)
    local dhost="$4"    # destination host:port
    local dport="$5"    # destination host:port

    [ -z "$proto" -o -z "$ifname" -o -z "$sport" -o -z "$dhost" -o -z "$dport" ] && {
        log "Not enough arguments: $@"
        exit 1
    }

    #
    # Sanity checks
    #
    case "$proto" in
        tcp|udp)
            ;;
        *)
            log "Invalid protocol: $proto"
            exit 2
            ;;
    esac

    echo "$ifname" | grep -q -E "^[a-z0-9.-]+$" || {
        log "Invalid interface: $ifname"
        exit 2
    }

    [ "$sport" -gt 1 -a "$sport" -lt 65536 ] || {
        log "Invalid source port: $sport"
        exit 2
    }

    [ "$dport" -gt 1 -a "$dport" -lt 65536 ] || {
        log "Invalid destination port: $dport"
        exit 2
    }

    echo "$dhost" | grep -q -E '^([0-9]{1,3}\.){3}[0-9]{1,3}' || {
        log "Invalid IP address: $dhost"
        exit 2
    }

    log "Adding port forward $proto $ifname:$sport -> $dhost:$dport"

    iptables -t nat -A NM_PORT_FORWARD -i "$ifname" -p "$proto" --dport "$sport" -j DNAT --to-destination "$dhost:$dport"
}

#
# Dump current firewall rules
#
iptables_dump()
{
    echo "========== iptables =========="
    for TABLE in filter nat
    do
        echo "===== $TABLE ====="
        iptables -t $TABLE --list -n -v | sed -e 's/	/        /g'
    done

    echo "========== ip6tables  =========="
    for TABLE in filter
    do
        echo "===== $TABLE ====="
        ip6tables -t $TABLE --list -n -v | sed -e 's/	/        /g'
    done
}

#
# miniupnpd support functions
#
upnpd_stop()
{
    start-stop-daemon -b -K -x "$UPNP_BIN"
}

upnpd_start()
{
    local ext_if=$1     # External interface
    local int_if=$2     # Internal interface

    [ -z "$1" -o -z "$2" ] && {
        log "UPnP requires 2 arguments."
        exit 1
    }

    [ -d "$UPNP_DIR" ] || mkdir -p "$UPNP_DIR" || {
        log "Unable to create temporary UPNP DIR: $UPNP_DIR"
        exit 1
    }

    touch "${UPNP_DIR}/miniupnpd.conf" || {
        log "Unable to create the UPnPD config file: ${UPNP_DIR}/miniupnpd.conf"
        exit 1
    }

    # Generate the miniupnpd config file
    cat > ${UPNP_DIR}/miniupnpd.conf <<-EOF
		ext_ifname=${ext_if}
		listening_ip=${int_if}
		enable_natpmp=yes
		enable_upnp=yes
		secure_mode=yes
		system_uptime=yes
		lease_file=${UPNP_DIR}/upnpd.leases
		allow 1024-65535 0.0.0.0/0 1024-65535
		deny 0-65535 0.0.0.0/0 0-65535
	EOF

    echo "Enabling UPnP on ext:$ext_if to int:$int_if"

    start-stop-daemon -b -S -x "$UPNP_BIN" -- -d -f "${UPNP_DIR}/miniupnpd.conf" || {
        log "Error starting miniupnpd"
        exit 1
    }
}


case "$1" in
    "boot")
        # Initialize iptables, set default policies etc. Must be called once per boot.
        iptables_boot 2>&1 | to_syslog
        ip6tables_boot 2>&1 | to_syslog
        ;;

    "flush")
        # Reset firewall and UPnP status
        iptables_flush 2>&1 | to_syslog
        ;;

    "lan")
        # Flag interface as lan (locally all input connection)
        iptables_lan "$2" 2>&1 | to_syslog
        ip6tables_lan "$2" 2>&1 | to_syslog
        ;;

    "nat")
        # Enable NAT on interface
        iptables_nat "$2" 2>&1 | to_syslog
        ;;

    "forward")
        # Forward a port
        iptables_forward "$2" "$3" "$4" "$5" "$6" 2>&1 | to_syslog
        ;;
    "upnp")
        # UPnP service
        upnpd_start "$2" "$3" 2>&1 | to_syslog
        ;;

    "dump")
        iptables_dump
        ;;
    *)
        log "Unknown command: $@"
        exit 1
        ;;
esac

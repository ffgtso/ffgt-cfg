#!/bin/bash
#
# Usage: $0 `uname -n` <tunnels.in
#
# Expects line with these arguments on stdin:
#
# localhost-remotehost cost
#
# Local host & remote host names are 1 field, separated by "-"; you must
# not use "-" in a host's name.
# Cost is the OSPF cost for the link.
#
# Where $1 matches either hostname, an entry is written, e. g.:
# --<8--
# ospf-gw05:
#   ipv4src: "10.255.145.46"
#   ipv4dst: "10.255.145.47"
#   pub4src: "144.76.59.58"
#   pub4dst: "195.138.247.80"
#   ipv6src: "2001:bf7:1310:30f::1"
#   ipv6dst: "2001:bf7:1310:30f::2"
#   cost: "100"
# -->8--
#

function get_v4_addr {
    v4_looked_up_addr=`LANG=C host -t A "$1"|awk '/has address/ {print $NF;}'`
}

if [ $# -ne 1 ]; then
    echo "Usage: $0 \`uname -n\` <tunnels.in"
    exit 1
fi

MYNAME="$1"
FQDNSUFFIX="4830.org"

get_v4_addr "${MYNAME}.${FQDNSUFFIX}"
localpubv4="$v4_looked_up_addr"


while IFS= read -r line; do
    mytunnel=0
    tunnelname="`echo \"${line}\" | cut -f 1 -d ' '`"
    tunnelcost="`echo \"${line}\" | cut -f 2 -d ' '`"
    lhost="`echo \"${tunnelname}\" | cut -f 1 -d '-'`"
    rhost="`echo \"${tunnelname}\" | cut -f 2 -d '-'`"
    if [ "${lhost}" = "${MYNAME}" ]; then
	mytunnel=1
	echo "ospf-${rhost}:"
	get_v4_addr "${rhost}.${FQDNSUFFIX}"
	remotepubv4="${v4_looked_up_addr}"
	echo "  pub4src: \"${localpubv4}\""
	echo "  pub4dst: \"${remotepubv4}\""
	/usr/local/bin/tun-ip.sh "${tunnelname}" |tr '\n' ' ' | awk '{printf("  ipv4src: \"%s\"\n  ipv6src: \"%s\"\n", $2, $4);}'
	/usr/local/bin/tun-ip.sh "${rhost}-${lhost}" |tr '\n' ' ' | awk '{printf("  ipv4dst: \"%s\"\n  ipv6dst: \"%s\"\n", $2, $4);}'
	echo "  cost: \"${tunnelcost}\""
	echo
    elif [ "${rhost}" = "${MYNAME}" ]; then
	mytunnel=1
	echo "ospf-${lhost}:"
	get_v4_addr "${lhost}.${FQDNSUFFIX}"
	remotepubv4="${v4_looked_up_addr}"
	echo "  pub4src: \"${localpubv4}\""
	echo "  pub4dst: \"${remotepubv4}\""
	/usr/local/bin/tun-ip.sh "${rhost}-${lhost}" |tr '\n' ' ' | awk '{printf("  ipv4src: \"%s\"\n  ipv6src: \"%s\"\n", $2, $4);}'
	/usr/local/bin/tun-ip.sh "${tunnelname}" |tr '\n' ' ' | awk '{printf("  ipv4dst: \"%s\"\n  ipv6dst: \"%s\"\n", $2, $4);}'
	echo "  cost: \"${tunnelcost}\""
	echo
    fi
done


#!/bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/jffs/sbin:/jffs/bin:/jffs/usr/sbin:/jffs/usr/bin:/mmc/sbin:/mmc/bin:/mmc/usr/sbin:/mmc/usr/bin:/opt/sbin:/opt/bin:/opt/usr/sbin:/opt/usr/bin

PPP_DEV=ppp0
VPN_DEV=ppp1

IP_VIA_PPP=/jffs/vpn/ip-via-ppp.txt
ROUTES_FILE=/jffs/vpn/ip-CN.txt

PPP_GATEWAY=$(ifconfig $PPP_DEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
VPN_GATEWAY=$(ifconfig $VPN_DEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
PPTPSERVER=$(nvram get pptpd_client_srvip)

ipviappp() {
	/usr/bin/awk '{print $1,$2}' $IP_VIA_PPP | while read ip mask; do
		/sbin/route add -net $ip netmask $mask dev $PPP_DEV
	done
}

vpnup() {
	/sbin/route add -host $PPTPSERVER dev $PPP_DEV
	/sbin/route add -host $PPTPSERVER gw $PPP_GATEWAY
	/sbin/route del -net 0.0.0.0 gw $PPP_GATEWAY
	/sbin/route add -net 0.0.0.0 gw $VPN_GATEWAY
	ipviappp
	/jffs/vpn/switch-dnsmasq.sh gfw
}

vpndown() {
	/sbin/route del -host $PPTPSERVER dev $PPP_DEV
	/sbin/route del -host $PPTPSERVER gw $PPP_GATEWAY
	/sbin/route del -net 0.0.0.0 gw $VPN_GATEWAY
	/sbin/route add -net 0.0.0.0 gw $PPP_GATEWAY
	/jffs/vpn/switch-dnsmasq.sh
}

wanup() {
	/usr/bin/awk '{print $1,$2}' $ROUTES_FILE | while read ip mask; do
		/sbin/route add -net $ip netmask $mask dev $PPP_DEV
	done
}

case $1 in
	"vpnup" )
		vpnup
	;;
	"vpndown" )
		vpndown
	;;
	"wanup" )
		wanup
	;;
	"ipviappp" )
		ipviappp
	;;
esac

/usr/sbin/iptables -t nat -A POSTROUTING -o $PPP_DEV -j MASQUERADE
/usr/sbin/iptables -t nat -A POSTROUTING -o $VPN_DEV -j MASQUERADE


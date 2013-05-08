#!/bin/sh

LOCAL_FILE=/jffs/vpn/dnsmasq-gfw.txt

/bin/cp -f /tmp/dnsmasq.conf /tmp/dnsmasq-gfw.conf

case $1 in
	"gfw" )
		/bin/cat "${LOCAL_FILE}" >> /tmp/dnsmasq-gfw.conf
	;;
esac

/usr/bin/killall dnsmasq ; dnsmasq --conf-file=/tmp/dnsmasq-gfw.conf

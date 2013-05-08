#!/bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/jffs/sbin:/jffs/bin:/jffs/usr/sbin:/jffs/usr/bin:/mmc/sbin:/mmc/bin:/mmc/usr/sbin:/mmc/usr/bin:/opt/sbin:/opt/bin:/opt/usr/sbin:/opt/usr/bin

APNIC_FILE=/jffs/vpn/apnic.txt
ROUTES_FILE=/jffs/vpn/ip-CN.txt

rm -f "${ROUTES_FILE}"

num2mask() {
	local mask
	case $1 in
		1) mask=255.255.255.255;;
		2) mask=255.255.255.254;;
		4) mask=255.255.255.252;;
		8) mask=255.255.255.248;;
		16) mask=255.255.255.240;;
		32) mask=255.255.255.224;;
		64) mask=255.255.255.192;;
		128) mask=255.255.255.128;;
		256) mask=255.255.255.0;;
		512) mask=255.255.254.0;;
		1024) mask=255.255.252.0;;
		2048) mask=255.255.248.0;;
		4096) mask=255.255.240.0;;
		8192) mask=255.255.224.0;;
		16384) mask=255.255.192.0;;
		32768) mask=255.255.128.0;;
		65536) mask=255.255.0.0;;
		131072) mask=255.254.0.0;;
		262144) mask=255.252.0.0;;
		524288) mask=255.248.0.0;;
		1048576) mask=255.240.0.0;;
		2097152) mask=255.224.0.0;;
		4194304) mask=255.192.0.0;;
		8388608) mask=255.128.0.0;;
		16777216) mask=255.0.0.0;;
		33554432) mask=254.0.0.0;;
		67108864) mask=252.0.0.0;;
		134217728) mask=248.0.0.0;;
		268435456) mask=240.0.0.0;;
		536870912) mask=224.0.0.0;;
		1073741824) mask=192.0.0.0;;
		2147483648) mask=128.0.0.0;;
		*) mask=255.255.255.0;;
	esac
	echo $mask
}
echo "Fetching..."
/usr/bin/wget -q http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest -O "${APNIC_FILE}"
echo "Processing..."
/bin/grep 'apnic|CN|ipv4|' ${APNIC_FILE} | awk 'FS="|"{print $4,$5}' | while read ip num
do
	mask=$(num2mask $num)
	echo "${ip} ${mask}">>${ROUTES_FILE}
done
rm -f "${APNIC_FILE}"
echo "Done."


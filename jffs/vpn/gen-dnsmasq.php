#!/usr/bin/php

<?php
error_reporting(E_ALL);

$url = 'http://autoproxy-gfwlist.googlecode.com/svn/trunk/gfwlist.txt';
$localFile = '/jffs/vpn/dnsmasq-gfw.txt';

$skipedDomains = array(
	'*',
	'apple.com',
	'sina.cn',
	'sina.com.cn',
	'baidu.com'
);

echo "Fetching gfwlist.txt ...\n";
$content = base64_decode(file_get_contents($url));
echo "Processing list...\n";
$content = preg_replace('#\!.+\n#iU', '', $content);
$content = str_replace('|', '', $content);
$content = str_replace('@', '', $content);
$content = str_replace('http://', '', $content);
$content = str_replace('https://', '', $content);
$list = explode("\n", $content);
$newList = array();
foreach ($list as $idx=>$row) {
	$row = trim($row);
	if (empty($row)) {
		continue;
	}
	if (strpos($row, '.') === false) {
		// not a valid domain.
		continue;
	}
	foreach ($skipedDomains as $skipedString) {
		if (strpos($row, $skipedString) !== false) {
			continue 2;
		}
	}
	if (!preg_match('#^[0-9a-zA-Z\-.]+$#isU', $row)) {
		continue;
	}
	$row = preg_replace('#^\.(.+)#isU', '$1', $row);
	$row = preg_replace('#^(.+)/.*$#isU', '$1', $row);
	$newList[] = 'server=/'.trim($row).'/8.8.8.8';
}
$newList = array_unique($newList);
asort($newList);
echo count($newList) . " hosts found.\n";
$content = "\n#--------- AUTO GENERATED ---------\n" . implode("\n", $newList);
file_put_contents($localFile, $content);
echo "{$localFile} Saved.\n";
echo "Done.\n";
exit;
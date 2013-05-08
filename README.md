DD-WRT 用的一些脚本
=====================

[@我是志一](http://weibo.com/liuzhiyi)  
Blog: [一路凯歌 | 技术博客](http://zhiyi.us "一路凯歌 | 技术博客")

当前支持：

* 无缝 Cross Wall（PPTP方式）

测试的环境：  
Buffalo WZR-HP-G450H  
DD-WRT v24SP2-MULTI (09/27/12) std

## 快速开始

* 开启 DNSMasq
* 开启 PPTP Client，确认pptp能正常连接
* 开启 jffs. See http://www.dd-wrt.com/wiki/index.php/Jffs
* 拷贝jffs目录的所有文件到router的 /jffs
* `chmod +x /jffs/vpn/*.sh`
* `chmod +x /jffs/vpn/*.php`
* `chmod +x /jffs/etc/config/setvpn.wanup
* 修改 /jffs/vpn/pptpd_client/options.vpn 为你自己的设置
* 把不想走 VPN 的 IP 加入 `ip-via-ppp.txt`
* Web 界面下重新拨号

## 无缝Cross Wall原理

* 所有国内IP走正常WAN接口；
* 所有国外IP走VPN接口；
* 国内IP列表从APNIC获得并自动处理；
* 大部分blocked domains(从gfwlist获得)通过8.8.8.8解析避免DNS污染；

## 文件说明

* `vpn/gen-cn-ip-routes.sh`
        从 APNIC 获取IP地址分配表并从中取出国内IP。
        几个礼拜运行一次即可。

* `vpn/gen-dnsmasq.php`
        获取 gfwlist 并且把其中的域名转换成DNSMasq配置文件格式来用8.8.8.8解析。
        隔几天运行一次。
        TODO: 更好的解析gfwlist

* `dnsmasq-gfw.txt` 和 `ip-CN.txt`
        上面两个脚本自动生成的文件，不能删除，但可以根据需要手动更改。

* `vpn/ip-updown.sh`
        WAN 和 PPTP Client 连接和断开时调用的脚本，进行设置路由表和iptables还有域名之类工作。
        （当前只支持PPTP）

* `vpn/switch-dnsmasq.sh`
        切换gfwlist里的域名用8.8.8.8还是本地DNS解析，VPN连接和断开时自动调用。

* `vpn/ip-via-ppp.txt`
        不走 VPN 接口的IP。

## 故障排除

### PPTP无法拨成功

1. 确认账号密码和IP在其他机器可以拨成功。
2. 调试 `/tmp/pptpd_client/options.vpn` 直到成功。
3. 注意wanup的时候会用`/jffs/vpn/pptpd_client/options.vpn`替换掉`/tmp/pptpd_client/options.vpn`，调试成功后用你的options.vpn替换掉jffs下的文件。

### VPN已连通但国外IP没走VPN接口或者国内IP都走了VPN接口

1. 当前只支持PPTP
2. 看你的PPTP接口是否是PPP1，如果不是自行更改`vpn/ip-updown.sh`
3. 看`/jffs/etc/config/setvpn.wanup`是否可执行
4. 看`/tmp/pptpd_client/ip-up` 里是否调用了`ip-updown.sh vpnup`
5. 手工执行 `vpn/ip-updown.sh vpnup` 后再看看是否走了VPN接口
6. 参照下述执行流行读脚本自己检查看问题在哪...

## 执行流程简介

1. WAN拨号后，系统自动调用 `etc/config/setvpn.wanup`
2. PPTP客户端接口UP后，系统自动通过`/tmp/pptpd_client/ip-up`调用`/jffs/vpn/ip-updown.sh vpnup`

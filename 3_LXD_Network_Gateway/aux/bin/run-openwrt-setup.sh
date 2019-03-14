lxc exec gateway ash
opkg update
opkg install squid luci-app-squid squid-mod-cachemgr libustream-openssl ca-bundle ca-certificates

echo "/etc/squid/squid.conf" >>/etc/sysupgrade.conf
squid -k reconfigure
squid -z
squid

/etc/init.d/firewall reload
/etc/init.d/firewall restart


#################################################################################
#TODO:    
# https://forum.archive.openwrt.org/viewtopic.php?id=53770    
# REFRENCE:    
# https://openwrt.org/docs/guide-user/services/proxy/proxy.squid    
# http://mini-stack/cgi-bin/cachemgr.cgi    

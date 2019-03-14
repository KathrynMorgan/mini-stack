pull_config_files () {
wget -O /etc/config/dhcp      https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/3_LXD_Network_Gateway/aux/config/dhcp
wget -O /etc/config/dropbear  https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/3_LXD_Network_Gateway/aux/config/dropbear
wget -O /etc/config/firewall  https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/3_LXD_Network_Gateway/aux/config/firewall
wget -O /etc/config/luci      https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/3_LXD_Network_Gateway/aux/config/luci
wget -O /etc/config/network   https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/3_LXD_Network_Gateway/aux/config/network
wget -O /etc/config/rpcd      https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/3_LXD_Network_Gateway/aux/config/rpcd
wget -O /etc/config/squid     https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/3_LXD_Network_Gateway/aux/config/squid
wget -O /etc/config/system    https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/3_LXD_Network_Gateway/aux/config/system
wget -O /etc/config/ucitrack  https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/3_LXD_Network_Gateway/aux/config/ucitrack
wget -O /etc/config/uhtpd     https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/3_LXD_Network_Gateway/aux/config/uhttpd
wget -O /etc/squid/squid.conf https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/3_LXD_Network_Gateway/aux/squid.conf 
}

run_squid_config () {
mkdir -p /tmp/squid/cache
mkdir -p /usr/lib/squid/log_file_daemon
echo "/etc/squid/squid.conf" >>/etc/sysupgrade.conf
/etc/init.d/squid enable
/etc/init.d/squid stop
chmod 0777 -R /tmp/squid/
squid -z
/etc/init.d/squid start
squid -k reconfigure
}

echo "Build Complete" && reboot

#################################################################################
#TODO:    
# https://forum.archive.openwrt.org/viewtopic.php?id=53770    
# REFRENCE:    
# https://openwrt.org/docs/guide-user/services/proxy/proxy.squid    
# http://mini-stack/cgi-bin/cachemgr.cgi    

wget -O /etc/config/dhcp      
wget -O /etc/config/dropbear  
wget -O /etc/config/firewall  
wget -O /etc/config/luci      
wget -O /etc/config/network   
wget -O /etc/config/rpcd     
wget -O /etc/config/squid    
wget -O /etc/config/system    
wget -O /etc/config/ucitrack 
wget -O /etc/config/uhtpd    
wget -O /etc/squid/squid.conf  

echo "/etc/squid/squid.conf" >>/etc/sysupgrade.conf

/etc/init.d/squid enable
/etc/init.d/squid stop
mkdir -p /usr/lib/squid/log_file_daemon
mkdir -p /tmp/squid/cache
chmod 0777 /tmp/squid/ -R
squid -z
/etc/init.d/squid start
squid -k reconfigure

reboot

#################################################################################
#TODO:    
# https://forum.archive.openwrt.org/viewtopic.php?id=53770    
# REFRENCE:    
# https://openwrt.org/docs/guide-user/services/proxy/proxy.squid    
# http://mini-stack/cgi-bin/cachemgr.cgi    

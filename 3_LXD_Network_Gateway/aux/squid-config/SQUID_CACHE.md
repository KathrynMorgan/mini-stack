```
opkg update
opkg install squid luci-app-squid squid-mod-cachemgr
```

```
cat <<EOF >>/etc/config/firewall
config redirect
        option proto 'tcp'
        option src 'lan'
        option src_ip '!192.168.1.1'
        option src_dport '80'
        option dest 'lan'
        option dest_ip '192.168.1.1'
        option dest_port '3128'
        option target 'DNAT'

EOF
```

```
/etc/init.d/firewall reload
/etc/init.d/firewall restart
```

```
cat <<EOF > /etc/squid/squid.conf
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl localnet src fc00::/7
acl localnet src fe80::/10

acl ssl_ports port 443

acl safe_ports port 80
acl safe_ports port 21
acl safe_ports port 443
acl safe_ports port 70
acl safe_ports port 210
acl safe_ports port 1025-65535
acl safe_ports port 280
acl safe_ports port 488
acl safe_ports port 591
acl safe_ports port 777
acl connect method connect

http_access deny !safe_ports
http_access deny connect !ssl_ports

http_access allow localhost manager
http_access deny manager

http_access deny to_localhost

http_access allow localnet
http_access allow localhost

http_access deny all

refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320

access_log none
cache_log /dev/null
cache_store_log stdio:/dev/null
logfile_rotate 0

logfile_daemon /dev/null

http_port 3128 intercept

# cache_dir aufs Directory-Name Mbytes L1 L2 [options]
cache_dir aufs /tmp/squid/cache 4086 16 512

# If you have 64 MB device RAM you can use 16 MB cache_mem, default is 8 MB
cache_mem 256 MB             
maximum_object_size_in_memory 64 MB
maximum_object_size 64 MB
EOF
```

```
echo "/etc/squid/squid.conf" >>/etc/sysupgrade.conf
squid -k reconfigure
squid -z
squid
```




TODO:
https://forum.archive.openwrt.org/viewtopic.php?id=53770
REFRENCE:
https://openwrt.org/docs/guide-user/services/proxy/proxy.squid
http://mini-stack/cgi-bin/cachemgr.cgi

#!/bin/ash

wan_IP=$(ip address show eth0 | awk -F'[ /]' '/inet /{print $6}')
cp /etc/config/firewall /root/bak/firewall.pre-maas-enable

sed -i "s/option local .*/option local '\/maas\/'/g" /etc/config/dhcp
sed -i "s/option domain .*/option domain 'maas'/g" /etc/config/dhcp
sed -i '/option ula_prefix/ s/^#*/#/' /etc/config/network

echo "

config redirect
        option target 'DNAT'
        option src 'wan'
        option dest 'lan'
        option proto 'tcp udp'
        option src_dport '5240'
        option dest_ip '10.10.0.10'
        option name 'MAAS-WebUI'
        option dest_port '5240'

" >>/etc/config/firewall

rm /usr/bin/enable-maas-webui-on-wan
mv /root/enable-maas-webui-on-wan /root/bak/
/etc/init.d/firewall reload

echo "
            ~~~~~~~~~~~~~~~~~~~~~
NOTICE: 
  Enabled MAAS WebUI Port Forward!

  Login [admin:admin] 
  http://${wan_IP}:5240/MAAS/


            ~~~~~~~~~~~~~~~~~~~~~
"

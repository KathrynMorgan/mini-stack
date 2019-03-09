
```
cat <<EOF >/etc/apt/apt.conf.d/99-disable-ipv6
Acquire::ForceIPv4 "true";
EOF
```
```
apt-get update && apt-get install -y openssh-server linux-generic-hwe-18.04
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/g' /etc/systemd/logind.conf
sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
systemctl set-default multi-user.target && systemctl default 
cp -f /etc/skel/.bashrc /root/.bashrc
mkdir /etc/default/grub.d
wget -P /etc/default/grub.d/ https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/0_Host_System_Prep/aux/libvirt-grub.cfg
update-grub
reboot
```


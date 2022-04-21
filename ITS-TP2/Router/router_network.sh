ip address flush dev ens161
ip address flush dev ens256
ip route flush dev ens161
ip route flush dev ens256
echo """
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto ens160
iface ens160 inet dhcp
    address 192.168.93.158
    netmask 255.255.255.0

auto ens161
iface ens161 inet static
    address 10.10.10.1
    network 10.10.10.0
    netmask 255.255.255.0

auto ens256
iface ens256 inet static
    address 10.20.20.1
    network 10.20.20.0
    netmask 255.255.255.0
""" > /etc/network/interfaces
sudo systemctl restart networking
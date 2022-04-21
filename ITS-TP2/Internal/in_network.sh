ip address flush dev ens160
ip address flush dev ens256
ip route flush dev ens160
ip route flush dev ens256
echo """
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto ens160
iface ens160 inet dhcp
    address 192.168.93.132
    netmask 255.255.255.0

auto ens256
iface ens256 inet static
    address 10.20.20.10
    network 10.20.20.0
    netmask 255.255.255.0
    gateway 10.20.20.1
    broadcast 10.20.20.255

up ip route add 10.10.10.0/24 via 10.20.20.1 dev ens256
up ip route add 0/0 via 10.20.20.1 dev ens256
""" > /etc/network/interfaces
sudo systemctl restart networking
sudo dhclient
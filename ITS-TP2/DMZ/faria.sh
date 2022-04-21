ip address flush dev ens33
ip route flush dev ens33
ip address flush dev ens34
ip route flush dev ens34
echo """
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto ens33
iface ens33 inet dhcp
    address 192.168.172.136
    netmask 255.255.255.0

auto ens34
iface ens34 inet static
    address 10.10.10.10
    network 10.10.10.0
    netmask 255.255.255.0
    gateway 10.10.10.1
    broadcast 10.10.10.255

up ip route add 10.20.20.0/24 via 10.10.10.1 dev ens34
#down ip route del 10.20.20.0/24 via 10.10.10.1 dev ens34
up ip route add 192.168.93.0/24 via 10.10.10.1 dev ens34
#down ip route del 192.168.93.0/24 via 10.10.10.1 dev ens34
""" > /etc/network/interfaces
sudo systemctl restart networking
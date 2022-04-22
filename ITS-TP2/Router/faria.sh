ip address flush dev ens33
ip address flush dev ens34
ip address flush dev ens36
ip route flush dev ens33
ip route flush dev ens34
ip route flush dev ens36
echo """
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto ens33
iface ens33 inet dhcp
    address 192.168.172.141
    netmask 255.255.255.0

auto ens34
iface ens34 inet static
    address 10.10.10.1
    network 10.10.10.0
    netmask 255.255.255.0

auto ens36
iface ens36 inet static
    address 10.20.20.1
    network 10.20.20.0
    netmask 255.255.255.0
""" > /etc/network/interfaces
sudo systemctl restart networking
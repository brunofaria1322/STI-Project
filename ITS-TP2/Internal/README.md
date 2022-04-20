# Router Configuration
***INTERNAL***
- **ROUTER** = 10.20.20.3
- kerberos = 10.20.20.10
- datastore = 10.20.20.11
- ftp = 10.20.20.12
## Installation
```sh
sudo apt-get install net-tools
```
## Network Configuration
```sh
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
    netmask 255.255.255.0
""" > /etc/network/interfaces
sudo systemctl restart networking
```
## NetCat Testing
```sh
# dns
nc 10.10.10.10 domain -v
nc -u 10.10.10.10 domain -v
# mail
nc 10.10.10.10 pop3 -v
nc 10.10.10.10 imap -v
# smtp
nc 10.10.10.10 smtp -v
# www
nc 10.10.10.10 http -v
nc 10.10.10.10 https -v
# vpn-gw
nc 10.10.10.10 openvpn -v
nc -u 10.10.10.10 openvpn -v
```


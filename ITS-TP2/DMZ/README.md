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
    address 192.168.93.164
    netmask 255.255.255.0

auto ens256
iface ens256 inet static
    address 10.10.10.10
    netmask 255.255.255.0
""" > /etc/network/interfaces
sudo systemctl restart networking
```
## NetCat Listening
```sh
# dns
nc -l -p domain -v
nc -l -u -p domain -v
# mail
nc -l -p pop3 -v
nc -l -p imap -v
# smtp
nc -l -p smtp -v
# www
nc -l -p http -v
nc -l -p https -v
# vpn-gw
nc -l -p openvpn -v
nc -l -u -p openvpn -v
```





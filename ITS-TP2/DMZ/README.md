# Router Configuration
***INTERNAL***
- **ROUTER** = 10.20.20.3
- kerberos = 10.20.20.10
- datastore = 10.20.20.11
- ftp = 10.20.20.12
## Installation
```sh
sudo apt-get install net-tools
sudo apt-get install ufw
```
## Network Configuration
```sh
echo """
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto ens160
iface ens160 inet dhcp
    address 192.168.93.162
    netmask 255.255.255.0

auto ens256
iface ens256 inet static
    address 10.10.10.4
    netmask 255.255.255.0
""" > /etc/network/interfaces
sudo systemctl restart networking
```
## IPTables Configuration
```sh
sudo nc -l -u -p domain
```
## Netcat Testing
```sh
nc -vz 10.10.10.4 domain
nc -l -p domain
```


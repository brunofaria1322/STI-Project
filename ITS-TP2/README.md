# Router Configuration
***DMZ***
- **ROUTER** = 10.10.10.3
- dns = 10.10.10.10
- mail = 10.10.10.11
- smtp = 10.10.10.12
- www = 10.10.10.13
- vpn-gw = 10.10.10.14
***INTERNAL***
- **ROUTER** = 10.20.20.3
- kerberos = 10.20.20.10
- datastore = 10.20.20.11
- ftp = 10.20.20.12
***INTERNET***
- **ROUTER** = 192.168.93.158
- dns2 = "193.137.16.75"
- eden = "193.136.212.1"
## Installation
```sh
sudo apt-get install net-tools
```
## Network Configuration
```sh
bash ./router_network.sh
```
## IPTables Configuration
```sh
sudo ./iptables.sh
```

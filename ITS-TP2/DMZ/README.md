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
bash ./dmz_network.sh
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





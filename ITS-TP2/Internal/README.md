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
bash ./in_network.sh
```
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


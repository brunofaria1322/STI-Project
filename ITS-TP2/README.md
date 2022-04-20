# Router Configuration
***DMZ***
- **ROUTER** = 10.10.10.3
- DNS = 10.10.10.10
- mail = 10.10.10.11
- smtp = 10.10.10.12
- www = 10.10.10.13
- vpn-gw = 10.10.10.14
***INTERNAL***
- **ROUTER** = 10.20.20.3
- kerberos = 10.20.20.10
- datastore = 10.20.20.11
- ftp = 10.20.20.12
## Installation
```sh
################################################################################
sudo apt-get install net-tools
################################################################################
```
## Network Configuration
```sh
################################################################################
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
    address 10.10.10.3
    netmask 255.255.255.0

auto ens256
iface ens256 inet static
    address 10.20.20.3
    netmask 255.255.255.0
""" > /etc/network/interfaces
sudo systemctl restart networking
################################################################################
```
## IPTables Configuration
```sh
#Configure a Linux system to operate as a router (by enabling packet forwarding) between two IPv4 networks
echo 1 > /proc/sys/net/ipv4/ip_forward
# Clear firewall
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X
# DROP all chains
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP
## ssh from my pc
sudo iptables -A INPUT -s 192.168.93.158 -p tcp --dport ssh -j ACCEPT
## Firewall configuration to protect the router
# DNS name resolution requests sent to outside servers
sudo iptables -A INPUT -p tcp --dport domain -j ACCEPT
sudo iptables -A INPUT -p udp --dport domain -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport domain -j ACCEPT
sudo iptables -A OUTPUT -p udp --dport domain -j ACCEPT
# SSH  connections  to  the  router system if  originated  at  the  internal  network  or  at  the  VPN gateway 
sudo iptables -A INPUT -s 10.20.20.0/24 -p tcp --dport ssh -j ACCEPT
sudo iptables -A INPUT -s 10.10.10.10 -p tcp --dport ssh -j ACCEPT
## Firewall configuration to authorize direct communications (without NAT)
# DNS
iptables -A FORWARD -d 10.10.10.10 -p udp --dport domain -j ACCEPT
iptables -A FORWARD -d 10.10.10.10 -p tcp --dport domain -j ACCEPT
iptables -A FORWARD -s 10.10.10.10 -p udp --dport domain -j ACCEPT
iptables -A FORWARD -s 10.10.10.10 -p tcp --dport domain -j ACCEPT
# POP and IMAP connections to the mail server
iptables -A FORWARD -d 10.10.10.11 -p tcp --dport pop3 -j ACCEPT
iptables -A FORWARD -d 10.10.10.11 -p tcp --dport imap -j ACCEPT
# SMTP connections to the smtp server
iptables -A FORWARD -d 10.10.10.12 -p tcp --dport 25 -j ACCEPT
iptables -A FORWARD -d 10.10.10.12 -p tcp --dport 587 -j ACCEPT
# HTTP and HTTPS connections to the www server
iptables -A FORWARD -d 10.10.10.13 -p tcp --dport http -j ACCEPT
iptables -A FORWARD -d 10.10.10.13 -p tcp --dport https -j ACCEPT
# OpenVPN connections to the vpn-gw server.
iptables -A FORWARD -d 10.10.10.13 -p tcp --dport openvpn -j ACCEPT
iptables -A FORWARD -d 10.10.10.13 -p udp --dport openvpn -j ACCEPT
# VPN clients connected to the gateway (vpn-gw) should able to connect to the PosgreSQL service on the datastore server.
iptables -A FORWARD -d 10.20.20.11 -s 10.10.10.13 -p tcp --dport postgres -j ACCEPT
# VPN clients connected to vpn-gw server should be able to connect to Kerberos v5 service on the kerberos server. A maximum of 10 simultaneous connections are allowed
iptables -A FORWARD -d 10.20.20.10 -s 10.10.10.13 -p tcp --dport postgres -j NFQUEUE --queue-num 10

#Allow forwarding of packets from Internet to firewall external adress (DNAT)
#Allow FTP
iptables -t nat -A PREROUTING -d 87.248.214.97 -p tcp --dport ftp -j DNAT --to-destination 192.168.10.1
iptables -A FORWARD -d 192.168.10.1 -p tcp --dport ftp -j ACCEPT

iptables -t nat -A PREROUTING -d 87.248.214.97 -p tcp --dport ftp-data -j DNAT --to-destination 192.168.10.1
iptables -A FORWARD -d 192.168.10.1 -p tcp --dport ftp-data -j ACCEPT
#Allow SSH
iptables -t nat -A PREROUTING -d 87.248.214.97 -s 87.248.214.98 -p tcp --dport ssh -j DNAT --to-destination 192.168.10.2
iptables -t nat -A PREROUTING -d 87.248.214.97 -s 87.248.214.99 -p tcp --dport ssh -j DNAT --to-destination 192.168.10.2
iptables -A FORWARD -d 192.168.10.2 -s 87.248.214.98 -p tcp --dport ssh -j ACCEPT
iptables -A FORWARD -d 192.168.10.2 -s 87.248.214.99 -p tcp --dport ssh -j ACCEPT


#Allow forwarding of packets from internal networks to internet (SNAT)
#Allow DNS
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -p tcp --dport domain -j SNAT --to-source 87.248.214.97
iptables -A FORWARD -s 192.168.10.0/24 -p tcp --dport domain -j ACCEPT

iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -p udp --dport domain -j SNAT --to-source 87.248.214.97
iptables -A FORWARD -s 192.168.10.0/24 -p udp --dport domain -j ACCEPT
#Allow HTTP
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -p tcp --dport http -j SNAT --to-source 87.248.214.97
iptables -A FORWARD -s 192.168.10.0/24 -p tcp --dport http -j ACCEPT
#Allow HTTPS
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -p tcp --dport https -j SNAT --to-source 87.248.214.97
iptables -A FORWARD -s 192.168.10.0/24 -p tcp --dport https -j ACCEPT
#Allow SSH
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -p tcp --dport ssh -j SNAT --to-source 87.248.214.97
iptables -A FORWARD -s 192.168.10.0/24 -p tcp --dport ssh -j ACCEPT
#Allow FTP
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -p tcp --dport ftp -j SNAT --to-source 87.248.214.97
iptables -A FORWARD -s 192.168.10.0/24 -p tcp --dport ftp -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -p tcp --dport ftp-data -j SNAT --to-source 87.248.214.97
iptables -A FORWARD -s 192.168.10.0/24 -p tcp --dport ftp-data -j ACCEPT


#Allow packets from established connections (fixes passive FTP)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT



#Allow pings for testing purposes
#iptables -A FORWARD -p icmp -j ACCEPT
#iptables -A INPUT -p icmp -j ACCEPT
#iptables -A OUTPUT -p icmp -j ACCEPT


#Print all rules
iptables -L
################################################################################
```


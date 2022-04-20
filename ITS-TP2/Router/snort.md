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
```
## IPTables Configuration
```sh
DMZ="10.10.10.0";
ROUTER_DMZ="10.10.10.3";
DNS="10.10.10.10";
MAIL="10.10.10.11";
SMTP="10.10.10.12";
WWW="10.10.10.13";
VPN="10.10.10.14";
INTERNAL_NETWORK="10.20.20.0";
ROUTER_IN="10.20.20.3";
KERBEROS="10.20.20.10";
DATASTORE="10.20.20.11";
FTP="10.20.20.12"
ROUTER_VM="192.168.93.158"
DNS2="193.137.16.75"
EDEN="193.136.212.1"
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
sudo iptables -A INPUT -s $ROUTER_VM -p tcp --dport ssh -j ACCEPT
## Firewall configuration to protect the router
# DNS name resolution requests sent to outside servers
sudo iptables -A INPUT -p tcp --dport domain -j ACCEPT
sudo iptables -A INPUT -p udp --dport domain -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport domain -j ACCEPT
sudo iptables -A OUTPUT -p udp --dport domain -j ACCEPT
# SSH  connections  to  the  router system if  originated  at  the  internal  network  or  at  the  VPN gateway 
sudo iptables -A INPUT -s $INTERNAL_NETWORK/24 -p tcp --dport ssh -j ACCEPT
sudo iptables -A INPUT -s $DNS -p tcp --dport ssh -j ACCEPT
## Firewall configuration to authorize direct communications (without NAT)
# DNS
iptables -A FORWARD -d $DNS -p udp --dport domain -j ACCEPT
iptables -A FORWARD -d $DNS -p tcp --dport domain -j ACCEPT
iptables -A FORWARD -s $DNS -p udp --dport domain -j ACCEPT
iptables -A FORWARD -s $DNS -p tcp --dport domain -j ACCEPT
# POP and IMAP connections to the mail server
iptables -A FORWARD -d $MAIL -p tcp --dport pop3 -j ACCEPT
iptables -A FORWARD -d $MAIL -p tcp --dport imap -j ACCEPT
# SMTP connections to the smtp server
iptables -A FORWARD -d $SMTP -p tcp --dport smtp -j ACCEPT #25-mail
# HTTP and HTTPS connections to the www server
iptables -A FORWARD -d $WWW -p tcp --dport http -j ACCEPT
iptables -A FORWARD -d $WWW -p tcp --dport https -j ACCEPT
# OpenVPN connections to the vpn-gw server.
iptables -A FORWARD -d $WWW -p tcp --dport openvpn -j ACCEPT
iptables -A FORWARD -d $WWW -p udp --dport openvpn -j ACCEPT
# VPN clients connected to the gateway (vpn-gw) should able to connect to the PosgreSQL service on the datastore server.
iptables -A FORWARD -d $DATASTORE -s $WWW -p tcp --dport postgres -j ACCEPT
# VPN clients connected to vpn-gw server should be able to connect to Kerberos v5 service on the kerberos server. A maximum of 10 simultaneous connections are allowed
iptables -A FORWARD -d $KERBEROS -s $WWW -p tcp --dport kerberos -j NFQUEUE --queue-num 10
iptables -A FORWARD -d $KERBEROS -s $WWW -p udp --dport kerberos -j NFQUEUE --queue-num 10


# Firewall configuration for connections to the external IP address of the firewall (using NAT)
#Allow FTP
iptables -t nat -A PREROUTING -d $ROUTER_VM -p tcp --dport ftp -j DNAT --to-destination $FTP
iptables -t nat -A PREROUTING -d $ROUTER_VM -p tcp --dport ftp-data -j DNAT --to-destination $FTP
iptables -A FORWARD -d $FTP -p tcp --dport ftp -j ACCEPT
iptables -A FORWARD -d $FTP -p tcp --dport ftp-data -j ACCEPT
#Allow SSH
iptables -t nat -A PREROUTING -d $ROUTER_VM -s $DNS2 -p tcp --dport ssh -j DNAT --to-destination $DATASTORE
iptables -t nat -A PREROUTING -d $ROUTER_VM -s $EDEN -p tcp --dport ssh -j DNAT --to-destination $DATASTORE
iptables -A FORWARD -d $DATASTORE -s $DNS2 -p tcp --dport ssh -j ACCEPT
iptables -A FORWARD -d $DATASTORE -s $EDEN -p tcp --dport ssh -j ACCEPT


#Allow forwarding of packets from internal networks to internet (SNAT)
#Allow DNS
iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport domain -j SNAT --to-source $ROUTER_VM
iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport domain -j ACCEPT
iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p udp --dport domain -j SNAT --to-source $ROUTER_VM
iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p udp --dport domain -j ACCEPT
#Allow HTTP
iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport http -j SNAT --to-source $ROUTER_VM
iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport http -j ACCEPT
#Allow HTTPS
iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport https -j SNAT --to-source $ROUTER_VM
iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport https -j ACCEPT
#Allow SSH
iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport ssh -j SNAT --to-source $ROUTER_VM
iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport ssh -j ACCEPT
#Allow FTP
iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport ftp -j SNAT --to-source $ROUTER_VM
iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport ftp -j ACCEPT
iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport ftp-data -j SNAT --to-source $ROUTER_VM
iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport ftp-data -j ACCEPT


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


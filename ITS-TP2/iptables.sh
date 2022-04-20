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
## ssh from my pc
sudo iptables -A OUTPUT -s $ROUTER_VM -p tcp --sport ssh -j ACCEPT
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
sudo iptables -A FORWARD -d $DNS -p udp --dport domain -j ACCEPT
sudo iptables -A FORWARD -d $DNS -p tcp --dport domain -j ACCEPT
sudo iptables -A FORWARD -s $DNS -p udp --dport domain -j ACCEPT
sudo iptables -A FORWARD -s $DNS -p tcp --dport domain -j ACCEPT
# POP and IMAP connections to the mail server
sudo iptables -A FORWARD -d $MAIL -p tcp --dport pop3 -j ACCEPT
sudo iptables -A FORWARD -d $MAIL -p tcp --dport imap -j ACCEPT
# SMTP connections to the smtp server
sudo iptables -A FORWARD -d $SMTP -p tcp --dport smtp -j ACCEPT
# HTTP and HTTPS connections to the www server
sudo iptables -A FORWARD -d $WWW -p tcp --dport http -j ACCEPT
sudo iptables -A FORWARD -d $WWW -p tcp --dport https -j ACCEPT
# OpenVPN connections to the vpn-gw server.
sudo iptables -A FORWARD -d $WWW -p tcp --dport openvpn -j ACCEPT
sudo iptables -A FORWARD -d $WWW -p udp --dport openvpn -j ACCEPT
# VPN clients connected to the gateway (vpn-gw) should able to connect to the PosgreSQL service on the datastore server.
sudo iptables -A FORWARD -d $DATASTORE -s $WWW -p tcp --dport postgres -j ACCEPT
# VPN clients connected to vpn-gw server should be able to connect to Kerberos v5 service on the kerberos server. A maximum of 10 simultaneous connections are allowed
sudo iptables -A FORWARD -d $KERBEROS -s $WWW -p tcp --dport kerberos -j NFQUEUE --queue-num 10
sudo iptables -A FORWARD -d $KERBEROS -s $WWW -p udp --dport kerberos -j NFQUEUE --queue-num 10
# Firewall configuration for connections to the external IP address of the firewall (using NAT)
#Allow FTP
sudo iptables -t nat -A PREROUTING -d $ROUTER_VM -p tcp --dport ftp -j DNAT --to-destination $FTP
sudo iptables -t nat -A PREROUTING -d $ROUTER_VM -p tcp --dport ftp-data -j DNAT --to-destination $FTP
sudo iptables -A FORWARD -d $FTP -p tcp --dport ftp -j ACCEPT
sudo iptables -A FORWARD -d $FTP -p tcp --dport ftp-data -j ACCEPT
#Allow SSH
sudo iptables -t nat -A PREROUTING -d $ROUTER_VM -s $DNS2 -p tcp --dport ssh -j DNAT --to-destination $DATASTORE
sudo iptables -t nat -A PREROUTING -d $ROUTER_VM -s $EDEN -p tcp --dport ssh -j DNAT --to-destination $DATASTORE
sudo iptables -A FORWARD -d $DATASTORE -s $DNS2 -p tcp --dport ssh -j ACCEPT
sudo iptables -A FORWARD -d $DATASTORE -s $EDEN -p tcp --dport ssh -j ACCEPT
#Allow forwarding of packets from internal networks to internet (SNAT)
#Allow DNS
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport domain -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport domain -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p udp --dport domain -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p udp --dport domain -j ACCEPT
#Allow HTTP
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport http -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport http -j ACCEPT
#Allow HTTPS
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport https -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport https -j ACCEPT
#Allow SSH
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport ssh -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport ssh -j ACCEPT
#Allow FTP
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport ftp -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport ftp -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport ftp-data -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport ftp-data -j ACCEPT
#Allow packets from established connections (fixes passive FTP)
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
# DROP all chains
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP
#Print all rules
sudo iptables -L
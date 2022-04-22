DMZ="10.10.10.0";
ROUTER_DMZ="10.10.10.1";
DMZ_VM="10.10.10.10";
DNS=$DMZ_VM;
MAIL=$DMZ_VM;
SMTP=$DMZ_VM;
WWW=$DMZ_VM;
VPN=$DMZ_VM;
INTERNAL_NETWORK="10.20.20.0";
ROUTER_IN="10.20.20.1";
INTERNAL_VM="10.20.20.10";
KERBEROS=$INTERNAL_VM;
DATASTORE=$INTERNAL_VM;
FTP=$INTERNAL_VM;
ROUTER_VM="192.168.172.141";
INTERNET_IP="192.168.172.1";
DNS2=$INTERNET_IP;
EDEN=$INTERNET_IP;

#Configure a Linux system to operate as a router (by enabling packet forwarding) between two IPv4 networks
echo 1 > /proc/sys/net/ipv4/ip_forward
sudo modprobe ip_conntrack_ftp

# Clear firewall
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X

# DROP policy for all chains
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP

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
sudo iptables -A FORWARD -d $DNS -p tcp --dport domain -j ACCEPT
sudo iptables -A FORWARD -s $DNS -p tcp --dport domain -j ACCEPT
sudo iptables -A FORWARD -d $DNS -p udp --dport domain -j ACCEPT
sudo iptables -A FORWARD -s $DNS -p udp --dport domain -j ACCEPT
# SMTP connections to the smtp server
sudo iptables -A FORWARD -d $SMTP -p tcp --dport smtp -j ACCEPT
# POP and IMAP connections to the mail server
sudo iptables -A FORWARD -d $MAIL -p tcp --dport pop3 -j ACCEPT
sudo iptables -A FORWARD -d $MAIL -p tcp --dport imap -j ACCEPT
# HTTP and HTTPS connections to the www server
# Queue Para XSS
.+9
# OpenVPN connections to the vpn-gw server.
sudo iptables -A FORWARD -d $VPN -p tcp --dport openvpn -j ACCEPT
sudo iptables -A FORWARD -d $VPN -p udp --dport openvpn -j ACCEPT
# VPN clients connected to the gateway (vpn-gw) should able to connect to the PosgreSQL service on the datastore server.
# Queue Para SQL
sudo iptables -A FORWARD -d $DATASTORE -s $VPN -p tcp --dport postgres -j NFQUEUE --queue-num 0
# VPN clients connected to vpn-gw server should be able to connect to Kerberos v5 service on the kerberos server. A maximum of 10 simultaneous connections are allowed
sudo iptables -A FORWARD -d $KERBEROS -s $VPN -p tcp --dport kerberos -m connlimit --connlimit-upto 10 -j ACCEPT
sudo iptables -A FORWARD -d $KERBEROS -s $VPN -p udp --dport kerberos -m connlimit --connlimit-upto 10 -j ACCEPT


## Firewall configuration for connections to the external IP address of the firewall (using NAT)
# FTP connections (in passive and active modes) to the ftp server
sudo iptables -t nat -A PREROUTING -d $ROUTER_VM -p tcp --dport ftp -j DNAT --to-destination $FTP
sudo iptables -t nat -A PREROUTING -d $ROUTER_VM -p tcp --dport ftp-data -j DNAT --to-destination $FTP
sudo iptables -A FORWARD -d $FTP -p tcp --dport ftp -j ACCEPT
sudo iptables -A FORWARD -d $FTP -p tcp --dport ftp-data -j ACCEPT
# SSH connections to the datastore server, but only if originated at the eden or dns2 servers
sudo iptables -t nat -A PREROUTING -d $ROUTER_VM -s $DNS2 -p tcp --dport ssh -j DNAT --to-destination $DATASTORE
sudo iptables -t nat -A PREROUTING -d $ROUTER_VM -s $EDEN -p tcp --dport ssh -j DNAT --to-destination $DATASTORE
sudo iptables -A FORWARD -d $DATASTORE -s $DNS2 -p tcp --dport ssh -j ACCEPT
sudo iptables -A FORWARD -d $DATASTORE -s $EDEN -p tcp --dport ssh -j ACCEPT


## Firewall configuration for communications from the internal network to the outside (using NAT)
# Domain name resolutions using DNS
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport domain -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport domain -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p udp --dport domain -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p udp --dport domain -j ACCEPT
# HTTP, HTTPS and SSH connections
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport http -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport http -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport https -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport https -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport ssh -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport ssh -j ACCEPT
# FTP connections (in passive and active modes) to external FTP servers
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport ftp -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport ftp -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NETWORK/24 -p tcp --dport ftp-data -j SNAT --to-source $ROUTER_VM
sudo iptables -A FORWARD -s $INTERNAL_NETWORK/24 -p tcp --dport ftp-data -j ACCEPT

#Allow packets from established connections (fixes passive FTP)
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

#Print all rules
sudo iptables -nvL

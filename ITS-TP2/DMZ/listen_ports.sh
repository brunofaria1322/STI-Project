# 53 (domain)
# 110 (pop3)
# 143 (imap2)
# 25 (smtp)
# 80 (http)
# 443 (https)
# 1194 (openvpn)

TCP_PORTS="53 110 143 25 80 443 1194";
UDP_PORTS="53 1194";
for port in $TCP_PORTS; do 
    nc -l -v -p $port & 
done;
for port in $UDP_PORTS; do 
    nc -l -vu -p $port & 
done;

# nc -lvp 80
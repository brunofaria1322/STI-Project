# 53 (domain)
# 110 (pop3)
# 143 (imap2)
# 25 (smtp)
# 80 (http)
# 443 (https)
# 1194 (openvpn)

PORTS="53 110 143 25 80 443 1194";
for port in $PORTS; do 
    nc -l -v -p $port & 
done;
# 22 (ssh)
# 53 (domain)
# 110 (pop3)
# 143 (imap2)
# 25 (smtp)
# 80 (http)
# 443 (https)
# 1194 (openvpn)

DMZ_NETWORK="10.10.10.10";
PORTS="22 53 110 143 25 80 443 1194";
for port in $PORTS; do 
    nc -n -w 1 -vz $DMZ_NETWORK $port; #tcp
    #nc -n -w 1 -uvz $DMZ_NETWORK $port; #udp
done;
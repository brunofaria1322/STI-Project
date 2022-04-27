# 22 (ssh)
# 53 (domain)
# 110 (pop3)
# 143 (imap2)
# 25 (smtp)
# 80 (http)
# 443 (https)
# 1194 (openvpn)

NETWORK="10.10.10.10";
TCP_PORTS="22 53 110 143 25 80 443 1194";
UDP_PORTS="22 1194";
for port in $TCP_PORTS; do 
    nc -n -w 1 -z $NETWORK $port; #tcp
    if [ $? -eq 0 ]; then
        echo "✅ TCP - Port $port is open";
    else
        echo "❌ TCP - Port $port is closed";
    fi;
done;
for port in $UDP_PORTS; do 
    nc -n -w 1 -uz $NETWORK $port; #udp
    if [ $? -eq 0 ]; then
        echo "✅ UDP - Port $port is open";
    else
        echo "❌ UDP - Port $port is closed";
    fi;
done;

#nc -n -w 1 $NETWORK 80
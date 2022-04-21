# 88 (kerberos)
# 5432 (postgres)

NETWORK="10.20.20.10";
TCP_PORTS="88 5432";
UDP_PORTS="88 5432";
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
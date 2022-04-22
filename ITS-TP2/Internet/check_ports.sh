# 20 (ftp-data)
# 21 (ftp)
# 22 (ssh) -> posgres

NETWORK="192.168.93.158";
TCP_PORTS=("20" "21" "22");

for port in $TCP_PORTS; do 
    echo $port;
    nc -n -w 1 -z $NETWORK $port -v;
    if [ $? -eq 0 ]; then
        echo "✅ TCP - Port $port is open";
    else
        echo "❌ TCP - Port $port is closed";
    fi;
done;

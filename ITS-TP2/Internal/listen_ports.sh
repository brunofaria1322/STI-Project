# 20 (ftp-data)
# 21 (ftp)
# 88 (kerberos)
# 5432 (postgres)

TCP_PORTS="20 21 88 5432";
UDP_PORTS="88 5432";


for port in $TCP_PORTS; do 
    nc -l -v -p $port & 
done;
for port in $UDP_PORTS; do 
    nc -l -vu -p $port & 
done;

# nc -lvp 20
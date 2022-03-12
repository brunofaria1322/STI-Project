# Lisboa Virtual Machine
## Initial Configuration
1. First Network Adaptor is NAT.
2. Create new Network Adaptor (Host-Only) and set IPv4 address to `192.168.172.60` with mask `255.255.255.0`
3. Create new Network Adaptor (Host-Only) and set IPv4 address to `10.10.0.1` with mask `255.255.255.0`
4. Set the hostname to `lisboa`
```sh
nano /etc/hostname
```
3. Copy Keys & Certs from Coimbra
```sh
sti@coimbra $ sudo scp -r /etc/pki/CA sti@192.168.172.60:~
```
```sh
sudo mv ~/CA /etc/pki/CA
cd /etc/pki/CA/
find . -type f ! \( \
    -name "dh2048.pem" \
    -o -name "ca.crt" \
    -o -name "apache.key" \
    -o -name "apache.crt" \
    -o -name "tun1-lisboa.key" \
    -o -name "tun1-lisboa.crt" \
    -o -name "ta.key" \
\) -delete
rm -rf crl
rm -rf ca
rm -rf ocsp 
rm -rf newcerts
rm -rf apache
```
## OpenVPN Tunnel
```sh
#Install OpenVPN
sudo apt-get install openvpn
#Start Service
sudo systemctl start openvpn
sudo systemctl enable openvpn
```

### Config TUN0
```sh
cd /etc/openvpn/
touch server.conf
echo "
local       192.168.172.60
port        1194 # DIFFERENT FROM TUN1
proto       udp
dev         tun
ca          /etc/pki/CA/certs/ca.crt
cert        /etc/pki/CA/certs/tun1-lisboa.crt
key         /etc/pki/CA/private/tun1-lisboa.key
dh          /etc/pki/CA/openvpn/dh2048.pem
server      10.9.0.0 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp.txt
push        \"route 10.7.0.0 255.255.255.0\"
push        \"route 10.8.0.0 255.255.255.0\"
push        \"route 10.10.0.0 255.255.255.0\"
keepalive   10 120
tls-auth   /etc/pki/CA/private/ta.key 0 
cipher      AES-256-CBC
persist-key
persist-tun
status      /var/log/openvpn/openvpn-status.log
verb        3
explicit-exit-notify 1
" > server.conf
#sudo openvpn --config server.conf      #manualmente
sudo systemctl daemon-reload
sudo systemctl restart openvpn@server
# wait for passphrase prompt
sudo systemd-tty-ask-password-agent --query
# enter passphrase (sti2022)
sudo systemctl enable openvpn@server
sudo systemctl status openvpn@server
```
***Kill all processes:***
- `sudo systemctl stop openvpn@server`
- `sudo systemctl disable openvpn@server`
- `sudo killall openvpn`

## Apache Server
```sh
#Install apache
sudo apt-get install apache2
sudo a2enmod ssl
sudo systemctl restart apache2
```

### Configure Apache with Certificate
```sh
cd /etc/apache2/sites-enabled
sudo a2ensite default-ssl
echo "
<IfModule mod_ssl.c>
    <VirtualHost _default_:443>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
        SSLEngine on
        SSLCertificateFile      /etc/pki/CA/certs/apache.crt
        SSLCertificateKeyFile   /etc/pki/CA/private/apache.key
        SSLCACertificateFile    /etc/pki/CA/certs/ca.crt
        <FilesMatch \"\.(cgi|shtml|phtml|php)\$\">
            SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
            SSLOptions +StdEnvVars
        </Directory>
    </VirtualHost>
</IfModule>
" >  default-ssl.conf

sudo service apache2 restart
```

### Set "apache" name for IP 127.0.0.1
Add `127.0.0.1        apache` line to `/etc/hosts`

### Install the CA on the browser and repeat the previous test

Example in Firefox:
1. Go to `Settings`
2. Go to `Privacy & Security`
3. Go to `Certificates`
4. Click `View Certificate`
5. Go to `Authorities`
6. Click in `Import`
7. Import `ca.crt`

***Important***
- URL needs to be the same name as the apache key
- In this case try the connection with `https://apache`

## Startup Commands
```bash
#Network
sudo dhclient
sudo systemctl restart NetworkManager

#Apache
sudo service apache2 restart

#enable ip forward
sudo sysctl -w net.ipv4.ip_forward=1
#                                   -s ip_vpnIn     -o tunOut?
sudo iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o tun0 -j MASQUERADE
#sudo iptables -t nat -A POSTROUTING -s 10.7.0.0/24 -o tun1 -j MASQUERADE
```
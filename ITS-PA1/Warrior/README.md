# Lisboa Virtual Machine

## Initial Configuration
1. First Network Adaptor is NAT.
2. Create new Network Adaptor (Host-Only) and set IPv4 address to `192.168.172.50` with mask `255.255.255.0`
3. Set the hostname to `client`
```sh
nano /etc/hostname

```
3. Copy Keys & Certs from Coimbra
```sh
sti@coimbra $ sudo scp -r /etc/pki/CA sti@192.168.172.50:~
```
```sh
sudo scp -r /etc/pki/CA sti@192.168.172.50:~
sudo mv ~/CA /etc/pki/CA
cd /etc/pki/CA/
find . -type f ! \( \
    -name "dh2048.pem" \
    -o -name "ca.crt" \
    -o -name "tun0-client.key" \
    -o -name "tun0-client.crt" \
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
touch client.conf
echo "
client
dev         tun
proto       udp
remote      192.168.172.70 1195
resolv-retry infinite
nobind
persist-key
persist-tun
ca          /etc/pki/CA/certs/ca.crt
cert        /etc/pki/CA/certs/tun0-client.crt
key         /etc/pki/CA/private/tun0-client.key
tls-auth    /etc/pki/CA/private/ta.key 1
cipher      AES-256-CBC
verb        3
" > client.conf
# check config
#sudo openvpn --config client.conf      #manualmente
# start service
sudo systemctl daemon-reload
sudo systemctl start openvpn@client
# wait for passphrase prompt
sudo systemd-tty-ask-password-agent --query
# enter passphrase (sti2022)
sudo systemctl enable openvpn@client
sudo systemctl status openvpn@client
```

## Google Auth
```sh
cd /etc/openvpn/
touch client.conf
echo "
auth-user-pass
client
dev         tun
proto       udp
remote      192.168.172.70 1195
resolv-retry infinite
nobind
persist-key
persist-tun
ca          /etc/pki/CA/certs/ca.crt
cert        /etc/pki/CA/certs/tun0-client.crt
key         /etc/pki/CA/private/tun0-client.key
tls-auth    /etc/pki/CA/private/ta.key 1
cipher      AES-256-CBC
verb        3
" > client.conf
# check config
sudo openvpn --config client.conf
```

## Apache with HTTPS

### set "apache" name for IP 10.10.0.1
Add `10.10.0.1        apache` line to `/etc/hosts`
```sh
nano /etc/hosts
```

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
```
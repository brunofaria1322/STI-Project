# Lisboa Virtual Machine
## Initial Configuration
1. Set IPv4 address to `192.168.172.50` with mask `255.255.255.0`
2. Set the hostname to `client`
```sh
nano /etc/hostname

```
3. Copy Keys & Certs from Coimbra

```sh
sti@coimbra $ sudo scp -r /etc/pki/CA sti@192.168.172.50:~
sti@client:~$ sudo mv CA /etc/pki/CA
```

## OpenVPN Tunnel
```shell
#Install OpenVPN
sudo apt-get install openvpn
#Start Service
sudo systemctl start openvpn
sudo systemctl enable openvpn
```
### Config TUN0
```shell
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
#tls-auth   /etc/pki/CA/private/ta.key 1
#cipher      AES-256-CBC
verb        3
" > client.conf
# check config
sudo openvpn --config client.conf
# start service
sudo systemctl daemon-reload
sudo systemctl start openvpn@client
# wait for passphrase prompt
sudo systemd-tty-ask-password-agent --query
# enter passphrase (sti2022)
sudo systemctl enable openvpn@client
sudo systemctl status openvpn@client
```


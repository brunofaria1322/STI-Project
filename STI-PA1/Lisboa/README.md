# Lisboa Virtual Machine
## Initial Configuration
1. Set IPv4 address to `192.168.172.60` with mask `255.255.255.0`
2. Set the hostname to `lisboa`
```sh
nano /etc/hostname
```
3. Copy Keys & Certs from Coimbra
```sh
root@coimbra $ scp -r /etc/pki/CA <user>@<VM IP>:/home/<user>
root@lisboa $ mv CA /etc/pki/CA
```
## OpenVPN Tunnel
### Config TUN0
```shell
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
server      10.10.0.0 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp.txt
keepalive   10 120
#tls-auth   /etc/pki/CA/private/ta.key 0 
cipher      AES-256-CBC
persist-key
persist-tun
status      /var/log/openvpn/openvpn-status.log
verb        3
explicit-exit-notify 1
" > server.conf
sudo openvpn --config server.conf
sudo systemctl daemon-reload
sudo systemctl start openvpn@server
# wait for passphrase prompt
systemd-tty-ask-password-agent --query
# enter passphrase (sti2022)
sudo systemctl enable openvpn@server
sudo systemctl status openvpn@server
```

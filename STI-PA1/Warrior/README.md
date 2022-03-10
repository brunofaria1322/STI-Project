# Lisboa Virtual Machine
## Initial Configuration
1. Set IPv4 address to `192.168.172.50` with mask `255.255.255.0`
2. Set the hostname to `client`
```sh
nano /etc/hostname

```
3. Copy Keys & Certs from Coimbra

```sh
root@coimbra $ scp -r /etc/pki/CA <user>@<VM IP>:/home/<user>
root@client $ mv CA /etc/pki/CA
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

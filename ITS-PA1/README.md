# Initial Configuration
## Tools
```shell
sudo apt-get install openvpn
sudo apt-get install net-tools
sudo apt-get install sysvinit-utils
PATH=$PATH:/usr/sbin
```
## Create Service
1. In terminal run:
```
sudo nano /lib/systemd/system/vpn-tunX.service
```
2. Paste:
```service
[Unit]
Description=
After=multi-user.target

[Service]
User=
Type=idle
WorkingDirectory=
Environment=""
ExecStart=bash <file>

[Install]
WantedBy=multi-user.target
```
3. In terminal run
```
sudo systemctl daemon-reload
sudo systemctl enable vpn-tunX
sudo systemctl start vpn-tunX
sudo systemctl status vpn-tunX
```
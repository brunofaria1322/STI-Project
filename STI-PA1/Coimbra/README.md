# Coimbra Virtual Machine
## Initial Configuration
1. Set IPv4 address to `192.168.172.70` with mask `255.255.255.0`
2. Set the hostname to `coimbra`
```sh
nano /etc/hostname
```
## CA Creation
```sh
nano /etc/ssl/openssl.cnf
```
```nginx
    ...
    ####################################################################
    [ CA_default ]

    dir             = /etc/pki/CA

    certs           = $dir/certs            # Where the issued certs are kept
    crl_dir         = $dir/crl              # Where the issued crl are kept
    database        = $dir/index.txt        # database index file.
    #unique_subject = no                    # Set to 'no' to allow creation of
                                            # several certs with same subject.
    new_certs_dir   = $dir/newcerts         # default place for new certs.

    certificate     = $dir/certs/ca.crt     # The CA certificate
    serial          = $dir/serial           # The current serial number
    crlnumber       = $dir/crlnumber        # the current crl number
                                            # must be commented out to leave a V1 CRL
    crl             = $dir/crl/ca.crl       # The current CRL
    private_key     = $dir/private/ca.key   # The private key

    x509_extensions = usr_cert              # The extensions to add to the cert
    ...
```
```sh
# Creates directories
mkdir /etc/pki/CA
cd /etc/pki/CA/
mkdir private
mkdir ca
mkdir certs
mkdir newcerts
mkdir crl
# Diretorias em falta na diretoria CA
touch index.txt
echo 01 > serial
echo 01 > crlnumber
# Key
openssl genrsa -des3 -out private/ca.key # pass: sti2022
# CSR
openssl req -new -key private/ca.key -out ca/ca.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=CA-Coimbra/emailAddress=ca-coimbra@gmail.com
# Certificate
openssl x509 -req -days 3650 -in ca/ca.csr -out certs/ca.crt -signkey private/ca.key
# Shows AC certificate content
openssl x509 -in certs/ca.crt -text
```
## OSCP Responder
### OCSP Certificate
```shell
cd /etc/pki/CA/
mkdir ocsp
# Key
openssl genrsa -des3 -out private/ocsp.key # pass: sti2022
# CSR
openssl req -new -key private/ocsp.key -out ocsp/ocsp.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=OCSP/emailAddress=ocsp@gmail.com
# Certificate
openssl ca -in ocsp/ocsp.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/ocsp.crt
```
### Run OCSP Responder
```shell
cd /etc/pki/CA/
openssl ocsp -index index.txt -port 81 -rsigner certs/ocsp.crt -rkey private/ocsp.key -CA certs/ca.crt -text -out log.txt
# Verify certificates
#openssl ocsp -CAfile certs/ca.crt -issuer certs/ca.crt -cert certs/name.crt -url http://192.168.172.70:81 -resp_text
```
### OCSP Service
```shell
#cd /etc/pki/CA/
# ! desencriptar a chave????? Unica forma de meter num serviço
#openssl rsa -in private/ocsp.key -out private/new_ocsp.key
#cd /lib/systemd/system
#sudo touch ocsp-coimbra.service
#echo "
#[Unit]
#Description=OCSP Responder of Coimbra
#After=multi-user.target

#[Service]
#User=root
#Type=idle
#WorkingDirectory=/etc/pki/CA
#ExecStart=openssl ocsp -index index.txt -port 81 -rsigner certs/ocsp.crt -rkey private/new_ocsp.key -CA certs/ca.crt -text -out log.txt

#[Install]
#WantedBy=multi-user.target
#" > ocsp-coimbra.service
#sudo systemctl daemon-reload
#sudo systemctl enable ocsp-coimbra.service
#sudo systemctl start ocsp-coimbra.service
# check if working
#sudo systemctl status ocsp-coimbra.service
```
## OpenVPN Tunnels
```shell
cd /etc/pki/CA/
mkdir apache
mkdir openvpn
# diffie-hellmann
openssl dhparam -out openvpn/dh2048.pem 2048
# tls-auth
# https://openvpn.net/community-resources/hardening-openvpn-security/
sudo openvpn --genkey secret private/ta.key
```
### Cert TUN0-Client
```shell
cd /etc/pki/CA/
# Key
openssl genrsa -des3 -out private/tun0-client.key # pass: sti2022
# CSR
openssl req -new -key private/tun0-client.key -out openvpn/tun0-client.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=TUN0-Client/emailAddress=tun0-client@gmail.com
# Certificate
openssl ca -in openvpn/tun0-client.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/tun0-client.crt
```
### Cert TUN0-Coimbra
```shell
cd /etc/pki/CA/
# Key
openssl genrsa -des3 -out private/tun0-coimbra.key # pass: sti2022
# CSR
openssl req -new -key private/tun0-coimbra.key -out openvpn/tun0-coimbra.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=TUN0-Coimbra/emailAddress=tun0-coimbra@gmail.com
# Certificate
openssl ca -in openvpn/tun0-coimbra.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/tun0-coimbra.crt
```
### Cert TUN1-Coimbra
```shell
cd /etc/pki/CA/
# Key
openssl genrsa -des3 -out private/tun1-coimbra.key # pass: sti2022
# CSR
openssl req -new -key private/tun1-coimbra.key -out openvpn/tun1-coimbra.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=TUN1-Coimbra/emailAddress=tun1-coimbra@gmail.com
# Certificate
openssl ca -in openvpn/tun1-coimbra.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/tun1-coimbra.crt
```
### Cert TUN1-Lisboa
```shell
cd /etc/pki/CA/
# Key
openssl genrsa -des3 -out private/tun1-lisboa.key # pass: sti2022
# CSR
openssl req -new -key private/tun1-lisboa.key -out openvpn/tun1-lisboa.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=TUN1-Lisboa/emailAddress=tun1-lisboa@gmail.com
# Certificate
openssl ca -in openvpn/tun1-lisboa.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/tun1-lisboa.crt
```
### Config TUN0
```shell
cd /etc/openvpn/
touch server.conf
echo "
local       192.168.172.70
port        1195 # DIFFERENT FROM TUN1
proto       udp
dev         tun
ca          /etc/pki/CA/certs/ca.crt
cert        /etc/pki/CA/certs/tun0-coimbra.crt
key         /etc/pki/CA/private/tun0-coimbra.key
dh          /etc/pki/CA/openvpn/dh2048.pem
server      10.8.0.0 255.255.255.0
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
```

### Config TUN1
```shell
cd /etc/openvpn/
touch client.conf
echo "
client
dev         tun
proto       udp
remote      192.168.172.60 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca          /etc/pki/CA/certs/ca.crt
cert        /etc/pki/CA/certs/tun1-coimbra.crt
key         /etc/pki/CA/private/tun1-coimbra.key
#tls-auth   /etc/pki/CA/private/ta.key 1
cipher      AES-256-CBC
verb        3
" > client.conf
# check config
sudo openvpn --config client.conf
sudo systemctl daemon-reload
sudo systemctl start openvpn@client
# wait for passphrase prompt
systemd-tty-ask-password-agent --query
# enter passphrase (sti2022)
sudo systemctl enable openvpn@client
sudo systemctl status openvpn@client
```

## Apache Server
### Cert Apache 
```shell
cd /etc/pki/CA/
# Key
openssl genrsa -des3 -out private/apache.key # pass: sti2022
# CSR
openssl req -new -key private/apache.key -out apache/apache.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=Apache/emailAddress=apache@gmail.com
# Certificate
openssl ca -in apache/apache.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/apache.crt
```




# IGNORE ================================================




## OpenVPN Tunnel
# server configuration file
```ssh
nano /etc/openvpn/client.conf
```
```nginx
# plugin openvpn-plugin-auth-pam.so openvpn
local   192.168.172.70
port    1194
proto   udp
dev     tun
ca      /etc/pki/CA/ca.crt
cert    /etc/pki/CA/certs/vpn-gatways.crt
key     /etc/pki/CA/private/vpn-gateways.key
dh      /etc/pki/CA/openvpn/dh2048.pem
server  10.8.0.0 255.255.255.0
# ifconfig-pool-persist ipp.txt
# client-config-dir .
# route 10.10.0.0 255.255.255.0
# client-to-client
# push "route 10.10.0.0 255.255.255.0"
# keepalive 10 120
# tls-auth /etc/pki/CA/private/ta.key 0
# cipher AES-256-CBC
# persist-key
# persist-tun
# status openvpn-status.log
# verb 3
# explicit-exit-notify 1
# tls-verify OCSP_check.sh
# script-security 2
```
```shell
sudo openvpn --config /etc/openvpn/server.conf
```






## Certificates Revocation
```shell
# Revokes name.crt certificate
#openssl ca -revoke certs/name.crt -keyfile private/ca.key -cert certs/ca.crt
# Creates new CRL file
openssl ca -gencrl -keyfile private/ca.key -cert certs/ca.crt -out crl/ca.crl
```
## OpenVPN Tunnel
# server configuration file
```ssh
nano /etc/openvpn/server.conf
```
```nginx
# plugin openvpn-plugin-auth-pam.so openvpn
local   192.168.172.70
port    1194
proto   udp
dev     tun
ca      /etc/pki/CA/ca.crt
cert    /etc/pki/CA/certs/vpn-gatways.crt
key     /etc/pki/CA/private/vpn-gateways.key
dh      /etc/pki/CA/openvpn/dh2048.pem
server  10.8.0.0 255.255.255.0
# ifconfig-pool-persist ipp.txt
# client-config-dir .
# route 10.10.0.0 255.255.255.0
# client-to-client
# push "route 10.10.0.0 255.255.255.0"
# keepalive 10 120
# tls-auth /etc/pki/CA/private/ta.key 0
# cipher AES-256-CBC
# persist-key
# persist-tun
# status openvpn-status.log
# verb 3
# explicit-exit-notify 1
# tls-verify OCSP_check.sh
# script-security 2
```
```shell
sudo openvpn --config /etc/openvpn/server.conf
```

# Notas
## Cert TUN0-Client
## Cert TUN0-Coimbra
!!!! OSCP pode 192.168.172.70
push route 0.0.0.0
IP forward
## Cert TUN1-Coimbra
## Cert TUN1-Lisboa
push route 10.8.0.0
!!!! Apache nao tem de ter o endereço do 192.168.172.60, tem de ser o locla
## Cert Apache
## Cert OCSP
!!!!! CUIDADO COM O BIND DOS TUNEIS OS PORTES TÊM DE SER DIFERENTES

!!! FAZER UM SERVICO PARA OS TUNEIS PARA ESTAR SEMPRE ATIVO

https://books.google.pt/books?id=_1MoDwAAQBAJ&pg=PA130&lpg=PA130&dq=systemd+pass+passphrse+openssl&source=bl&ots=CJpi1TxFVe&sig=ACfU3U2I-44hoS_LM-IRYgzGYLWXOMx4mQ&hl=en&sa=X&ved=2ahUKEwi29Zrt9rb2AhWN-aQKHapZC14Q6AF6BAgZEAM#v=onepage&q=systemd%20pass%20passphrse%20openssl&f=false

https://openvpn.net/community-resources/how-to/
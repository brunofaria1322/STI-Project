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
## Certificates Generation
```shell
# Diretorias em falta na diretoria CA
touch index.txt
echo 01 > serial
echo 01 > crlnumber
```
### Apache Server
```shell
cd /etc/pki/CA/
mkdir apache
# Key
openssl genrsa -des3 -out private/apache.key # pass: sti2022
# CSR
openssl req -new -key private/apache.key -out apache/apache.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=Apache-Lisboa
# Certificate
openssl ca -in apache/apache.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/apache.crt
```
### VPNs
```shell
cd /etc/pki/CA/
mkdir openvpn
# diffie-hellmann
openssl dhparam -out openvpn/dh2048.pem 2048
# tls-auth
# https://openvpn.net/community-resources/hardening-openvpn-security/
openvpn --genkey secret private/ta.key
```
#### VPN Gateways
```shell
# Key
openssl genrsa -des3 -out private/vpn-gateways.key 2048 # pass: sti2022
# CSR
openssl req -new -key private/vpn-gateways.key -out openvpn/vpn-gateways.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=VPN-Gateways
# Certificate
openssl ca -in openvpn/vpn-gateways.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/vpn-gateways.crt
```
#### VPN Clients
```shell
# Key
openssl genrsa -des3 -out private/vpn-clients.key 2048 # pass: sti2022
# CSR
openssl req -new -key private/vpn-clients.key -out openvpn/vpn-clients.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=VPN-Clients
# Certificate
openssl ca -in openvpn/vpn-clients.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/vpn-clients.crt
```


# TODOOOO - AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA


## Certificates Revocation
```shell
# Revokes name.crt certificate
#openssl ca -revoke certs/name.crt -keyfile private/ca.key -cert certs/ca.crt
# Creates new CRL file
openssl ca -gencrl -keyfile private/ca.key -cert certs/ca.crt -out crl/ca.crl
```
## OSCP Responder
```shell
openssl ocsp -index index.txt -port 81 -rsigner certs/ca.crt -rkey private/ca.key -CA certs/ca.crt -text -out log.txt
openssl ocsp -CAfile certs/ca.crt -issuer certs/ca.crt -cert certs/vpn-clients.crt -url http://192.168.172.70:81 -resp_text
```
## OpenVPN Tunnel
# server configuration file
```ssh
nano /etc/openvpn/server/server.conf
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

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
```apacheconf
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
# Creates assymetric key associated to the AC
openssl genrsa -des3 -out private/ca.key # pass: sti2022
openssl req -new -key private/ca.key -out ca/ca.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=CA-Coimbra/emailAddress=ca-coimbra@gmail.com
# Creates final certificate with CSR, signed with RSA key previously created
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
# Criação da chave privada do Apache
openssl genrsa -des3 -out private/apache.key # pass: sti2022
# Criação do CSR
openssl req -new -key private/apache.key -out apache/apache.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=Apache-Lisboa
# Criação do certificado para o utilizador Apache
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
openssl genrsa -des3 -out private/vpn-gateways.key 2048 # pass: sti2022
openssl req -new -key private/vpn-gateways.key -out openvpn/vpn-gateways.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=VPN-Gateways
openssl ca -in openvpn/vpn-gateways.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/vpn-gateways.crt
```
#### VPN Clients
```shell
# Key
openssl genrsa -des3 -out private/vpn-clients.key 2048 # pass: sti2022
# CSR
openssl req -new -key private/vpn-clients.key -out openvpn/vpn-clients.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=VPN-Clients
# Cert
openssl ca -in openvpn/vpn-clients.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/vpn-clients.crt
```
## Certificates Revocation
```shell
# Revokes name.crt certificate
#openssl ca -revoke certs/name.crt -keyfile private/ca.key -cert certs/ca.crt
# Creates new CRL file
openssl ca -gencrl -keyfile private/ca.key -cert certs/ca.crt -out crl.pem
```

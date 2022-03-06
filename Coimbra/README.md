# Coimbra Virtual Machine
## Initial Configuration
1. Set IPv4 address to `192.168.172.70` with mask `255.255.255.0`
2. Set the hostname to `coimbra`
```sh
nano /etc/hostname
```
## CA Creation
```sh
# Edit 'dir' directory to '/etc/pki/CA'
nano /etc/ssl/openssl.cnf
```
```conf
    dir     =   /etc/pki/CA
```
```sh
# Creates directories
mkdir /etc/pki/CA
cd /etc/pki/CA/
mkdir private
mkdir ca
mkdir certs
mkdir newcerts
# Creates assymetric key associated to the AC
openssl genrsa -des3 -out private/ca.key # pass: sti2022
openssl req -new -key private/ca.key -out ca/ca.csr
```
```makefile
    Country Name: PT
    State or Province Name: Coimbra
    Locality Name: Coimbra
    Organization Name: UC
    Organizational Unit Name: DEI
    Common Name: CA-Coimbra
    Email Address: ca-coimbra@gmail.com
```
```sh
# Creates final certificate with CSR, signed with RSA key previously created
openssl x509 -req -days 3650 -in ca/ca.csr -out certs/ca.crt -signkey private/ca.key
# Shows AC certificate content
openssl x509 -in certs/ca.crt -text
```
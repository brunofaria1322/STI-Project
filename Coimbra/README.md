# Criação da CA
```shell
# Edit 'dir' directory to '/etc/pki/CA'
nano /etc/ssl/openssl.cnf
```
    ```
        dir     /etc/pki/CA
    ```
```shell
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
    ```
        Country Name: PT
        State or Province Name: Coimbra
        Locality Name: Coimbra
        Organization Name: UC
        Organizational Unit Name: DEI
        Common Name: CA-Coimbra
        Email Address: ca-coimbra@gmail.com
    ```
```shell
# Creates final certificate with CSR, signed with RSA key previously created
openssl x509 -req -days 3650 -in ca/ca.csr -out certs/ca.crt -signkey private/ca.key
# Shows AC certificate content
openssl x509 -in certs/ca.crt -text
```
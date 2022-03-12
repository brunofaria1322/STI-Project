# Coimbra Virtual Machine
## Startup Commands
```bash
#Network
sudo dhclient
sudo systemctl restart NetworkManager

#enable ip forward
sudo sysctl -w net.ipv4.ip_forward=1
#                                   -s ip_vpnIn     -o tunOut?
sudo iptables -t nat -A POSTROUTING -s 10.7.0.0/24 -o tun0 -j MASQUERADE
## inverso não funcionava 


### Run OCSP Responder
su

cd /etc/pki/CA/
openssl ocsp -index index.txt -port 81 -rsigner certs/ocsp.crt -rkey private/ocsp.key -CA certs/ca.crt -text
```

## Initial Configuration
1. Set IPv4 address to `192.168.172.70` with mask `255.255.255.0`
2. Create new Network Adaptor. Set IPv4 address to `10.8.0.1` with mask `255.255.255.0`
3. Set the hostname to `coimbra`
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
    [ usr_cert ]
    ...
    authorityInfoAccess          = OCSP;URI:http://127.0.0.1:81
    
    [ v3_OCSP ]
    basicConstraints = CA:FALSE
    keyUsage = nonRepudiation, digitalSignature, keyEncipherment
    extendedKeyUsage = OCSPSigning
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
openssl genrsa -des3 -out private/ca.key  # pass: sti2022
# CSR
openssl req -new -key private/ca.key -out ca/ca.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=CA-Coimbra/emailAddress=ca-coimbra@gmail.com -passin pass:sti2022
# Certificate
openssl x509 -req -days 3650 -in ca/ca.csr -out certs/ca.crt -signkey private/ca.key -passin pass:sti2022
# Shows AC certificate content
#openssl x509 -in certs/ca.crt -text
```
## OSCP Responder
### OCSP Certificate
```sh
cd /etc/pki/CA/
mkdir ocsp
# Key
openssl genrsa -des3 -out private/ocsp.key # pass: sti2022
# CSR
openssl req -new -key private/ocsp.key -out ocsp/ocsp.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=OCSP/emailAddress=ocsp@gmail.com -passin pass:sti2022
# Certificate
openssl ca -in ocsp/ocsp.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/ocsp.crt -extensions v3_OCSP -passin pass:sti2022
# Shows AC certificate content
#openssl x509 -in certs/ocsp.crt -text
```
### Run OCSP Responder
```sh
cd /etc/pki/CA/
touch log.txt
openssl ocsp -index index.txt -port 81 -rsigner certs/ocsp.crt -rkey private/ocsp.key -CA certs/ca.crt -text
```
## OpenVPN Tunnels
```sh
#Install OpenVPN
sudo apt-get install openvpn
#Start Service
sudo systemctl start openvpn
sudo systemctl enable openvpn
cd /etc/pki/CA/
mkdir openvpn
# diffie-hellmann
openssl dhparam -out openvpn/dh2048.pem 2048
# tls-auth
# https://openvpn.net/community-resources/hardening-openvpn-security/
sudo openvpn --genkey secret private/ta.key
```
### Cert TUN0-Client
```sh
cd /etc/pki/CA/
# Key
openssl genrsa -des3 -out private/tun0-client.key # pass: sti2022
# CSR
openssl req -new -key private/tun0-client.key -out openvpn/tun0-client.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=TUN0-Client/emailAddress=tun0-client@gmail.com -passin pass:sti2022
# Certificate
openssl ca -in openvpn/tun0-client.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/tun0-client.crt -passin pass:sti2022
# Verify certificates
#openssl ocsp -CAfile certs/ca.crt -issuer certs/ca.crt -cert certs/tun0-client.crt -url http://192.168.172.70:81 -resp_text
```
### Cert TUN0-Coimbra
```sh
cd /etc/pki/CA/
# Key
openssl genrsa -des3 -out private/tun0-coimbra.key # pass: sti2022
# CSR
openssl req -new -key private/tun0-coimbra.key -out openvpn/tun0-coimbra.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=TUN0-Coimbra/emailAddress=tun0-coimbra@gmail.com -passin pass:sti2022
# Certificate
openssl ca -in openvpn/tun0-coimbra.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/tun0-coimbra.crt -passin pass:sti2022
# Verify certificates
#openssl ocsp -CAfile certs/ca.crt -issuer certs/ca.crt -cert certs/tun0-coimbra.crt -url http://192.168.172.70:81 -resp_text
```
### Cert TUN1-Coimbra
```sh
cd /etc/pki/CA/
# Key
openssl genrsa -des3 -out private/tun1-coimbra.key # pass: sti2022
# CSR
openssl req -new -key private/tun1-coimbra.key -out openvpn/tun1-coimbra.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=TUN1-Coimbra/emailAddress=tun1-coimbra@gmail.com -passin pass:sti2022
# Certificate
openssl ca -in openvpn/tun1-coimbra.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/tun1-coimbra.crt -passin pass:sti2022
```
### Cert TUN1-Lisboa
```sh
cd /etc/pki/CA/
# Key
openssl genrsa -des3 -out private/tun1-lisboa.key # pass: sti2022
# CSR
openssl req -new -key private/tun1-lisboa.key -out openvpn/tun1-lisboa.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=TUN1-Lisboa/emailAddress=tun1-lisboa@gmail.com -passin pass:sti2022
# Certificate
openssl ca -in openvpn/tun1-lisboa.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/tun1-lisboa.crt -passin pass:sti2022
```
### OCSP Check
```sh
cd /etc/pki/    # É propositado estar fora da diretoria CA
wget https://raw.githubusercontent.com/OpenVPN/openvpn/master/contrib/OCSP_check/OCSP_check.sh
sudo chmod 777 OCSP_check.sh
# Edit lines of OCSP_check.sh
nano OCSP_check.sh
```
```sh
...
    ocsp_url="http://127.0.0.1:81/"
    issuer="/etc/pki/CA/certs/ca.crt"
    nonce="-nonce"
    verify="/etc/pki/CA/certs/ca.crt"
...
```
### Config TUN0
```sh
cd /etc/openvpn/
touch server.conf
echo "
plugin      /usr/lib/openvpn/openvpn-plugin-auth-pam.so \"login login USERNAME password PASSWORD pin OTP\"

local       192.168.172.70
port        1195 # DIFFERENT FROM TUN1
proto       udp
dev         tun
ca          /etc/pki/CA/certs/ca.crt
cert        /etc/pki/CA/certs/tun0-coimbra.crt
key         /etc/pki/CA/private/tun0-coimbra.key
dh          /etc/pki/CA/openvpn/dh2048.pem
server      10.7.0.0 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp.txt
push        \"route 10.8.0.0 255.255.255.0\"
push        \"route 10.9.0.0 255.255.255.0\"
push        \"route 10.10.0.0 255.255.255.0\"
keepalive   10 120
tls-auth    /etc/pki/CA/private/ta.key 0 
cipher      AES-256-CBC
persist-key
persist-tun
status      /var/log/openvpn/openvpn-status.log

script-security 2
tls-verify /etc/pki/OCSP_check.sh

verb        3
explicit-exit-notify 1

" > server.conf

# check config
#sudo openvpn --config server.conf    #manualmente
# start service
sudo systemctl daemon-reload
sudo systemctl start openvpn@server
# wait for passphrase prompt
sudo systemd-tty-ask-password-agent --query
# enter passphrase (sti2022)
sudo systemctl enable openvpn@server
sudo systemctl status openvpn@server
```
***Kill all processes:***
- `sudo systemctl stop openvpn@server`
- `sudo systemctl disable openvpn@server`
- `sudo killall openvpn`

### Config TUN1
```sh
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
tls-auth    /etc/pki/CA/private/ta.key 1
cipher      AES-256-CBC
verb        3
" > client.conf
# check config
#sudo openvpn --config client.conf    #manualmente
# start service
sudo systemctl daemon-reload
sudo systemctl start openvpn@client
# wait for passphrase prompt
sudo systemd-tty-ask-password-agent --query
# enter passphrase (sti2022)
sudo systemctl enable openvpn@client
sudo systemctl status openvpn@client
```
***Kill all processes:***
- `sudo systemctl stop openvpn@client`
- `sudo systemctl disable openvpn@client`
- `sudo killall openvpn`

## Apache Server
### Cert Apache 
```sh
cd /etc/pki/CA/
mkdir apache
# Key
openssl genrsa -des3 -out private/apache.key # pass: sti2022
# CSR
openssl req -new -key private/apache.key -out apache/apache.csr -subj \
/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=Apache/emailAddress=apache@gmail.com -passin pass:sti2022
# Certificate
openssl ca -in apache/apache.csr -cert certs/ca.crt -keyfile private/ca.key -out certs/apache.crt -passin pass:sti2022
# Verify certificates
#openssl ocsp -CAfile certs/ca.crt -issuer certs/ca.crt -cert certs/apache.crt -url http://192.168.172.70:81 -resp_text
```
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


## Google Auth
```sh
# install libs
sudo apt-get install -y libqrencode4 libpam-google-authenticator
# config
addgroup gauth
useradd -g gauth gauth
sudo google-authenticator
mkdir google-authenticator
chown gauth:gauth google-authenticator 
chmod 0700 google-authenticator
```
Add the line:
- `plugin      /usr/lib/openvpn/openvpn-plugin-auth-pam.so "login login USERNAME password PASSWORD pin OTP"`
```sh
# add plugin into /etc/openvpn/server.conf
cd /etc/openvpn/
nano server.conf
# plugin      /usr/lib/openvpn/openvpn-plugin-auth-pam.so "login login USERNAME password PASSWORD pin OTP"
```
Add, at the beginning, the line:
- `auth required pam_google_authenticator.so secret=/etc/openvpn/google-authenticator/{USER} forward_pass`

(replace {USER} with the username)
```sh
# add config into /etc/pam.d/login
nano /etc/pam.d/login
#auth required pam_google_authenticator.so secret=/etc/openvpn/google-authenticator/<USER> forward_pass
```
```sh
su -c "google-authenticator -t -d -r3 -R30 -f -l 'OpenVPN Server' -s /etc/openvpn/google-authenticator/{USER}" - gauth
```

Scan the QR code with GoogleAuthenticator App

```
Your new secret key is: 6DGZQVG5E6SSWCLXKYCKXHJHPA
Enter code from app (-1 to skip): 962663
Code confirmed
Your emergency scratch codes are:
  38250790
  17829309
  86725593
  79778279
  47995335

By default, a new token is generated every 30 seconds by the mobile app.
In order to compensate for possible time-skew between the client and the server,
we allow an extra token before and after the current time. This allows for a
time skew of up to 30 seconds between authentication server and client. If you
experience problems with poor time synchronization, you can increase the window
from its default size of 3 permitted codes (one previous code, the current
code, the next code) to 17 permitted codes (the 8 previous codes, the current
code, and the 8 next codes). This will permit for a time skew of up to 4 minutes
between client and server.
Do you want to do so? (y/n) y
```
After that configure the client!


## Certificates Revocation
```sh
# Revokes name.crt certificate
#openssl ca -revoke certs/name.crt -keyfile private/ca.key -cert certs/ca.crt
# Creates new CRL file
openssl ca -gencrl -keyfile private/ca.key -cert certs/ca.crt -out crl/ca.crl
```
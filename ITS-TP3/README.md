## Utils
0. See WSTG
    
1. Download Docker:
    1. Install Docker:
        https://www.docker.com/products/docker-desktop/
    2. Install Container:
        https://hub.docker.com/r/bkimminich/juice-shop
        ```sh
        docker pull bkimminich/juice-shop
        docker run --rm -p 3000:3000 bkimminich/juice-shop
        ```
2. Go to Server:
    http://localhost:3000
    http://192.168.99.100:3000
    http://192.168.93.1:3000/
3. Install OWASP ZAP
    https://www.zaproxy.org/download/


## Installation on server-side
Not tested yet....
```sh
su -
apt-get update && apt-get upgrade
apt-get install -y npm
apt-get install -y docker
git clone https://github.com/juice-shop/juice-shop.git --branch v13.3.0 --depth 1
cd juice-shop
npm install
npm start
```

## Tesing

### Gathering information
1. Conduct Search Engine Discovery Reconnaissance for Information Leakage
```
site:192.168.93.1:3001
inurl:192.168.93.1:3001
intitle:192.168.93.1:3001
intext:192.168.93.1:3001
filetype:192.168.93.1:3001
```
2. Fingerprint Web Server
    2.1. NMap
    ```sh
    nmap 192.168.93.1 -p 3001
    ```
    ```
    tarting Nmap 7.92 ( https://nmap.org ) at 2022-05-27 17:35 WEST
    Nmap scan report for 192.168.93.1
    Host is up (0.00024s latency).

    PORT     STATE SERVICE
    3001/tcp open  nessus

    Nmap done: 1 IP address (1 host up) scanned in 0.06 seconds
    ```
    2.2. SSLScan
    ```sh
    sslscan 192.168.93.1:3001
    ```
    ```
    Connected to 192.168.93.1

    Testing SSL server 192.168.93.1 on port 3001 using SNI name 192.168.93.1

    SSL/TLS Protocols:
    SSLv2     disabled
    SSLv3     disabled
    TLSv1.0   disabled
    TLSv1.1   disabled
    TLSv1.2   disabled
    TLSv1.3   disabled

    TLS Fallback SCSV:
    Connection failed - unable to determine TLS Fallback SCSV support

    TLS renegotiation:
    Session renegotiation not supported

    TLS Compression:
    Compression disabled

    Heartbleed:

    Supported Server Cipher(s):
    Certificate information cannot be retrieved.
    ```
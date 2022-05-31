## Utils
1. Download Docker:
    1. Install Docker:
        https://www.docker.com/products/docker-desktop/
    2. Install Container:
        https://hub.docker.com/r/bkimminich/juice-shop
2. Go to Server:
    http://192.168.93.1:3001/


## Installation on server-side
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
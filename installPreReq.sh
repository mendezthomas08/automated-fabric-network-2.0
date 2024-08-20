#!/bin/bash

sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

 sudo mkdir -p /etc/apt/keyrings
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
 
 echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

 sudo apt-get update
 sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin    

 sudo usermod -aG docker $(whoami)

 echo "# Installing Docker-Compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.13.0/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Installing nodejs and npm"

sudo apt install -y nodejs

sudo apt install -y npm

sudo apt install -y jq

echo "Installing Fabric"

sudo chmod 666 /var/run/docker.sock

curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.2 1.5.3

echo "Installing GO"

wget https://golang.org/dl/go1.16.5.linux-amd64.tar.gz

sudo tar -xzf go1.16.5.linux-amd64.tar.gz -C /usr/local/

npm install -g pm2
echo " Open /etc/profile and add the below line"
echo "export PATH=$PATH:/usr/local/go/bin"

echo "sudo vi /etc/profile"

echo "After adding the line .Run 'source /etc/profile'"

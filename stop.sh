#!/bin/bash
# stopping the containers. Note that this will remove all existing docker containers
rm -rf crypto-config
rm -rf channel-artifacts
rm configtx.yaml
rm crypto-config.yaml
rm docker-compose.yaml
rm *.yaml
sudo rm -rf *-config/
rm *.txt
sudo rm -rf containers
sudo rm -rf persist
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer0.*/) {print $3}')
 if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
 else
    docker rmi -f $DOCKER_IMAGE_IDS
 fi

docker system prune --volumes -f

rm ./fabricSDK/config/network-config.json

rm ./fabricSDK/config/config.json

sudo rm -R ./fabricSDK/*-wallet

pm2 delete fabricapp


./stopExplorer.sh
echo -e "\e[36m###############################################################\e[0m"
echo -e "\e[36m#                 \e[5m\e[34m All \e[33mremoved \e[32msucessfully\e[0m\e[36m                    #\e[0m"
echo -e "\e[36m###############################################################\e[0m"

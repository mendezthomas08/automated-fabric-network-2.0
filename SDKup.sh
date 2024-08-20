#!/bin/bash

ORG_NAME="$1"
DOMAIN_NAME="$2"
NETWORK_NAME="$3"
CHANNEL_NAME="$4"
NUMBER_OF_PEERS="$5"



cd fabricSDK/config

# npm install

node networkconfigeditor.js $ORG_NAME $DOMAIN_NAME $CHANNEL_NAME $NUMBER_OF_PEERS

#./generate-ccp.sh $ORG_NAME $DOMAIN_NAME $CHANNEL_NAME

cd ..

echo
	if [ -d node_modules ]; then
		echo "============== node modules installed already ============="
	else
		echo "============== Installing node modules ============="
		npm install
	fi
echo


cat << EOF > ./docker-compose.yml
version: "2.1"

networks:
    default:
     external: 
         name: $NETWORK_NAME

services:
  api:
    image: api:1.0
    build: .
    ports:
      - 4000:4000
         
EOF
#pm2 start app.js --name fabricapp
docker-compose up -d



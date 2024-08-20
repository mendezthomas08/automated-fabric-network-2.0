#!/bin/bash

mkdir explorer
cd explorer

ORG_NAME="$1"
DOMAIN_NAME="$2"
NETWORK_NAME="$3"
CHANNEL_NAME="$4"



CURRENT_DIR=$PWD
cd ../crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/User1@$ORG_NAME.$DOMAIN_NAME.com/msp/keystore/
PRIVATE_KEY=$(ls *_sk)
cd "${CURRENT_DIR}"
cat << EOF > docker-compose.yaml
  
     # SPDX-License-Identifier: Apache-2.0
version: '2.1'

volumes:
  pgdata:
  walletstore:

networks:
    default:
     external: 
         name: $NETWORK_NAME
   

services:

  explorerdb.mynetwork.com:
    image: hyperledger/explorer-db:latest
    container_name: explorerdb.mynetwork.com
    hostname: explorerdb.mynetwork.com
    environment:
      - DATABASE_DATABASE=fabricexplorer
      - DATABASE_USERNAME=hppoc
      - DATABASE_PASSWORD=password
    healthcheck:
      test: "pg_isready -h localhost -p 5432 -q -U postgres"
      interval: 30s
      timeout: 10s
      retries: 5
    volumes:
      - pgdata:/var/lib/postgresql/data
    

  explorer.mynetwork.com:
    image: hyperledger/explorer:latest
    container_name: explorer.mynetwork.com
    hostname: explorer.mynetwork.com
    environment:
      - DATABASE_HOST=explorerdb.mynetwork.com
      - DATABASE_DATABASE=fabricexplorer
      - DATABASE_USERNAME=hppoc
      - DATABASE_PASSWD=password
      - LOG_LEVEL_APP=info
      - LOG_LEVEL_DB=info
      - LOG_LEVEL_CONSOLE=debug
      - LOG_CONSOLE_STDOUT=true
      - DISCOVERY_AS_LOCALHOST=false
      - PORT=8080
    volumes:
      - ./config.json:/opt/explorer/app/platform/fabric/config.json
      - ./connection-profile:/opt/explorer/app/platform/fabric/connection-profile
      - ../crypto-config:/tmp/crypto
      - walletstore:/opt/explorer/wallet
    ports:
      - 8080:8080
    depends_on:
      explorerdb.mynetwork.com:
        condition: service_healthy
   

EOF
mkdir connection-profile
cd connection-profile
cat <<EOF>> network-config.json
  {
        "name": "network-config",
        "version": "1.0.0",
        "client": {
                "tlsEnable": true,
                "adminCredential": {
                        "id": "exploreradmin",
                        "password": "exploreradminpw"
                },
                "enableAuthentication": true,
                "organization": "${ORG_NAME}MSP",
                "connection": {
                        "timeout": {
                                "peer": {
                                        "endorser": "300"
                                },
                                "orderer": "300"
                        }
                }
        },
        "channels": {
                "${CHANNEL_NAME}": {
                        "peers": {
                                "peer0.${ORG_NAME}.${DOMAIN_NAME}.com": {}
                        }
                }
        },
        "organizations": {
                "${ORG_NAME}MSP": {
                        "mspid": "${ORG_NAME}MSP",
                        "adminPrivateKey": {
                                "path": "/tmp/crypto/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/User1@${ORG_NAME}.${DOMAIN_NAME}.com/msp/keystore/$PRIVATE_KEY"
                        },
                        "peers": ["peer0.${ORG_NAME}.${DOMAIN_NAME}.com"],
                        "signedCert": {
                                "path": "/tmp/crypto/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/User1@${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/cert.pem"
                        }
                }
        },
        "peers": {
                "peer0.${ORG_NAME}.${DOMAIN_NAME}.com": {
                        "tlsCACerts": {
                                "path": "/tmp/crypto/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/ca.crt"
                        },
                        "url": "grpcs://peer0.${ORG_NAME}.${DOMAIN_NAME}.com:7051"
                }
        }
}

EOF
 
cd ..

cat <<EOF>> config.json

{
        "network-configs": {
                "network-config": {
                        "name": "Network Config",
                        "profile": "./connection-profile/network-config.json"
                }
        },
        "license": "Apache-2.0"
}

EOF


docker-compose up -d


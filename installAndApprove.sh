#!/bin/bash

function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31mUsage: \e[0m"
  echo -e "\e[32m\e[1minstallAndApprove.sh [<org name>] [<domain name> ] [<channel name>] [<Chaincode path>] [<Chaincode language>] [<cc label>] [<cc name>] "
  echo -e "\e[35m[<org name>]\e[0m= name of the org\e[0m"
  echo -e "\e[34m#############################################################################################\e[0m"
}

if [ "$#" = 0 ]; then
 printHelp
 exit 1
fi


ORG_NAME="$1"
DOMAIN_NAME="$2"
CHANNEL_NAME="$3"
CC_PATH="$4"
CC_LANG="$5"
CC_LABEL="$6"
CC_NAME="$7"
CC_VERSION="$8"
CC_SEQUENCE="$9"



docker cp ${CC_PATH}/.. cli:/opt/gopath/src/github.com/hyperledger/fabric/peer

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_PATH} --lang ${CC_LANG} --label ${CC_LABEL}

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode install ${CC_NAME}.tar.gz

#docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode queryinstalled

CC_PACKAGE_ID=$(docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode queryinstalled --output json | jq '.installed_chaincodes[0].package_id ' | tr -d '"')
#read -p "Enter chaincode package id : " CC_PACKAGE_ID
#export CC_PACKAGE_ID=basic_1:c54371bedb7aeb4be35d6458f3afbbed634c788d176d7d10283b1242c2efeeef
echo $CC_PACKAGE_ID
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode approveformyorg -o orderer.${DOMAIN_NAME}.com:7050 --ordererTLSHostnameOverride orderer.${DOMAIN_NAME}.com --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem" --channelID ${CHANNEL_NAME} --name ${CC_NAME} --version $CC_VERSION --package-id $CC_PACKAGE_ID --sequence $CC_SEQUENCE


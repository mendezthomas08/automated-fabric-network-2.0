#!/bin/bash

function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31mUsage: \e[0m"
  echo -e "\e[32m\e[1mchaincode_test.sh [<org name>] [<domain name> ] [<channel name>] "
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


docker cp asset-transfer-basic/ cli:/opt/gopath/src/github.com/hyperledger/fabric/peer

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode package basic.tar.gz --path ./asset-transfer-basic/chaincode-javascript/ --lang node --label basic_1

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode install basic.tar.gz 

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode queryinstalled


read -p "Enter chaincode package id : " CC_PACKAGE_ID
#export CC_PACKAGE_ID=basic_1:c54371bedb7aeb4be35d6458f3afbbed634c788d176d7d10283b1242c2efeeef

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode approveformyorg -o orderer.${DOMAIN_NAME}.com:7050 --ordererTLSHostnameOverride orderer.${DOMAIN_NAME}.com --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem" --channelID ${CHANNEL_NAME} --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 


docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode commit -o orderer.$DOMAIN_NAME.com:7050 --ordererTLSHostnameOverride orderer.$DOMAIN_NAME.com --channelID $CHANNEL_NAME --name basic --version 1.0 --sequence 1 --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/tlscacerts/tlsca.$DOMAIN_NAME.com-cert.pem" --peerAddresses peer0.$ORG_NAME.$DOMAIN_NAME.com:7051 --tlsRootCertFiles "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" --peerAddresses peer1.$ORG_NAME.$DOMAIN_NAME.com:7051 --tlsRootCertFiles "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer1.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt"


docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name basic --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem"


sleep 8


docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer chaincode invoke -o orderer.${DOMAIN_NAME}.com:7050 --ordererTLSHostnameOverride orderer.${DOMAIN_NAME}.com --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem" -C ${CHANNEL_NAME} -n basic --peerAddresses peer0.${ORG_NAME}.${DOMAIN_NAME}.com:7051 --tlsRootCertFiles "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/ca.crt" --peerAddresses peer0.${ORG_NAME}.${DOMAIN_NAME}.com:7051 --tlsRootCertFiles "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}' 

sleep 8
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer chaincode query -C $CHANNEL_NAME -n basic -c '{"Args":["GetAllAssets"]}'

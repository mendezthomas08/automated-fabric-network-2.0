#!/bin/bash
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.

function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31mUsage: \e[0m"
  echo -e "\e[32m\e[1mstart.sh [<org name>] "
  echo -e "\e[35m[<org name>]\e[0m= name of the org\e[0m"
  echo -e "\e[34m#############################################################################################\e[0m"
}

if [ "$#" = 0 ]; then
 printHelp
 exit 1
fi

ORG_NAME="$1"
DOMAIN_NAME="$2"
NETWORK_NAME="$3"
CHANNEL_NAME="$4"
NUMBER_OF_PEERS="$5"
#set -ev

echo "$DOMAIN_NAME $NETWORK_NAME $CHANNEL_NAME"
# don't rewrite paths for Windows Git Bash users


verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
    echo
    exit 1
  fi
}

docker-compose -f ./docker-compose.yaml up -d

# wait for Hyperledger Fabric to start

export FABRIC_START_TIMEOUT=14



echo "please wait ${FABRIC_START_TIMEOUT} second"


echo -e "\e[35mCreating channel ==>\e[5m$CHANNEL_NAME\e[0m"
echo -e "\e[93########################################\e[0m"

sleep ${FABRIC_START_TIMEOUT}

echo -ne "\r"


#docker exec -e "ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem" cli  peer channel create -o orderer.$DOMAIN_NAME.com:7050 -c $CHANNEL_NAME -f /var/hyperledger/channel-artifacts/$CHANNEL_NAME.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem>&magicScriptChannelErrorLog.txt

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli  peer channel create -o orderer.$DOMAIN_NAME.com:7050  --ordererTLSHostnameOverride orderer.$DOMAIN_NAME.com -c $CHANNEL_NAME -f /var/hyperledger/channel-artifacts/$CHANNEL_NAME.tx --outputBlock /var/hyperledger/channel-artifacts/$CHANNEL_NAME.block --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/tlscacerts/tlsca.$DOMAIN_NAME.com-cert.pem">&magicScriptChannelErrorLog.txt


verifyResult $res "Channel creation failed"
#cat log.txt

echo -e "\e[35mchannel created sucessfully\e[0m"
echo -e "\e[93#############################\e[0m"
###########################################
####
####
for (( i=0; i<$NUMBER_OF_PEERS; i++ )) do
docker exec -e "CORE_PEER_LOCALMSPID=${ORG_NAME}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer${i}.$ORG_NAME.$DOMAIN_NAME.com:7051" peer${i}.$ORG_NAME.$DOMAIN_NAME.com peer channel join -b /var/hyperledger/channel-artifacts/$CHANNEL_NAME.block >&magicScriptChannelErrorLog.txt
#docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli  peer channel join -b /var/hyperledger/channel-artifacts/$CHANNEL_NAME.block >&magicScriptChannelErrorLog.txt
res=$?


verifyResult $res "peer${i}.$ORG_NAME.$DOMAIN_NAME.com failed to join $CHANNEL_NAME"
#cat log.txt
####
echo -e "\e[35mpeer${i}.$ORG_NAME.$DOMAIN_NAME.com joined channel \e[5m$CHANNEL_NAME\e[0m"
echo -e "\e[93#######################################################################\e[0m"

done


docker exec -e "ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt"  cli  peer channel update -o orderer.$DOMAIN_NAME.com:7050 -c $CHANNEL_NAME -f /var/hyperledger/channel-artifacts/${ORG_NAME}MSPanchors.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem >&magicScriptChannelErrorLog.txt
res=$?


verifyResult $res "anchorPeer upate failed for $ORG_NAME"




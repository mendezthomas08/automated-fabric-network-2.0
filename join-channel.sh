#!/bin/bash

function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31mUsage: \e[0m"
  echo -e "\e[32m\e[1mjoin-channel.sh [<org name>] [<domain-name>] [<channel-name>] [<number -of -peers]"
  echo -e "\e[35m[<org name>]\e[0m= name of the org\e[0m"
  echo -e "\e[34m#############################################################################################\e[0m"
}

if [ "$#" = 0 ]; then
 printHelp
 exit 1
fi

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
    echo
    exit 1
  fi
}


ORG_NAME="$1"
DOMAIN_NAME="$2"
CHANNEL_NAME="$3"
NUMBER_OF_PEERS="$4"


for (( i=0; i<$NUMBER_OF_PEERS; i++ ))
do	

docker exec -e CORE_PEER_TLS_ENABLED=true -e CORE_PEER_LOCALMSPID="${ORG_NAME}MSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer${i}.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp -e CORE_PEER_ADDRESS=peer${i}.$ORG_NAME.$DOMAIN_NAME.com:7051 cli peer channel fetch 0 /var/hyperledger/channel-artifacts/$CHANNEL_NAME.block -o orderer.$DOMAIN_NAME.com:7050 --ordererTLSHostnameOverride orderer.$DOMAIN_NAME.com -c $CHANNEL_NAME --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/tlscacerts/tlsca.$DOMAIN_NAME.com-cert.pem"



docker exec -e CORE_PEER_TLS_ENABLED=true -e CORE_PEER_LOCALMSPID="${ORG_NAME}MSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer${i}.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp -e CORE_PEER_ADDRESS=peer${i}.$ORG_NAME.$DOMAIN_NAME.com:7051 cli  peer channel join -b /var/hyperledger/channel-artifacts/$CHANNEL_NAME.block >&joinChannelErrorLog.txt

#docker exec -e "CORE_PEER_LOCALMSPID=${ORG_NAME}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" peer0.$ORG_NAME.$DOMAIN_NAME.com peer channel join -b /var/hyperledger/channel-artifacts/$CHANNEL_NAME.block >&joinChannelErrorLog.txt
res=$?

verifyResult $res "peer${i}.$ORG_NAME.$DOMAIN_NAME.com failed to join $CHANNEL_NAME"


echo -e "\e[35mpeer${i}.$ORG_NAME.$DOMAIN_NAME.com joined channel \e[5m$CHANNEL_NAME\e[0m"
echo -e "\e[93#######################################################################\e[0m"

done

#docker exec -e "CORE_PEER_LOCALMSPID=${ORG_NAME}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" peer1.$ORG_NAME.$DOMAIN_NAME.com peer channel join -b /var/hyperledger/channel-artifacts/$CHANNEL_NAME.block >&joinChannelErrorLog.txt





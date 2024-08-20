#!/bin/bash

function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31mUsage: \e[0m"
  echo -e "\e[32m\e[1mcommit.sh [<mode>] [<org name>] [<domain name> ] [<channel name>] [<cc-name>] [<cc-version>] [<cc-sequence>] [<peersArray>] "
  echo -e "\e[35m[<org name>]\e[0m= name of the org\e[0m"
  echo -e "\e[34m#############################################################################################\e[0m"
}

if [ "$#" = 0 ]; then
 printHelp
 exit 1
fi

MODE="$1"
ORG_NAME="$2"
DOMAIN_NAME="$3"
CHANNEL_NAME="$4"
CHAINCODE_NAME="$5"
CC_VERSION="$6"
CC_SEQUENCE="$7"
PEERORGS="$#"

if [[ "$MODE" == "commit" || "$MODE" == "invoke" ]] 
then
CMD=""
for ((i = 8; i <= $#; i++ )); do
array[$i]=${!i}
done

for ((i = 8; i <= $PEERORGS; i++)); do
  PEERORG=${array[$i]}
  DIR_NAME="${PEERORG:6}"  
  docker cp ./crypto-config/peerOrganizations/$DIR_NAME cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations
  CMD+=" --peerAddresses $PEERORG:7051 --tlsRootCertFiles "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$DIR_NAME/peers/$PEERORG/tls/ca.crt""
done  

fi

function checkcommitreadiness(){
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CC_VERSION --sequence $CC_SEQUENCE --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/tlscacerts/tlsca.$DOMAIN_NAME.com-cert.pem" --output json

}

chaincodeCommit(){
  echo $CMD
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode commit -o orderer.$DOMAIN_NAME.com:7050 --ordererTLSHostnameOverride orderer.$DOMAIN_NAME.com --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CC_VERSION --sequence $CC_SEQUENCE --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/tlscacerts/tlsca.$DOMAIN_NAME.com-cert.pem" --peerAddresses peer0.$ORG_NAME.$DOMAIN_NAME.com:7051 --tlsRootCertFiles "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt"$CMD

}
function queryCommited(){
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name $CHAINCODE_NAME --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem"

}


function invoke(){
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer chaincode invoke -o orderer.${DOMAIN_NAME}.com:7050 --ordererTLSHostnameOverride orderer.${DOMAIN_NAME}.com --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem" -C ${CHANNEL_NAME} -n $CHAINCODE_NAME --peerAddresses peer0.${ORG_NAME}.${DOMAIN_NAME}.com:7051 --tlsRootCertFiles "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/ca.crt" --peerAddresses peer0.${ORG_NAME}.${DOMAIN_NAME}.com:7051 --tlsRootCertFiles "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/ca.crt"$CMD -c '{"function":"InitLedger","Args":[]}'
}
function query(){
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["GetAllAssets"]}'
}

if [ "$MODE" == "commit" ]
then
   chaincodeCommit
fi

if [ "$MODE" == "checkCommitReadiness" ]
then
    checkcommitreadiness
fi

if [ "$MODE" == "queryCommited" ]
then
     queryCommited
fi

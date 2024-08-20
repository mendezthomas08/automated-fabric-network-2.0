
#!/bin/bash
#
function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31mUsage: \e[0m"
  echo -e "\e[32m\e[1maddNewOrg.sh [<org name>] [<base org>] [<base -ip>] [<domain name>] [<network-name>] [<channel-name>] [<numberOfPeers>] \e[0m"
  echo -e "\e[35m[<org name>]\e[0m= name of the org\e[0m"
  echo -e "\e[35m[<Domain Name>]\e[0m= domain name of the org\e[0m"
  echo -e "\e[35m[<Network Name>]\e[0m= swarm overlay network name\e[0m"
  echo -e "\e[35m[<Channel Name>]\e[0m= name of the channel\e[0m"
  echo -e "\e[34m#############################################################################################\e[0m"
}

if [ "$#" = 0 ]; then
 printHelp
 exit 1
fi


ORG_NAME="$1"
BASE_ORG="$2"
BASE_IP="$3"
DOMAIN_NAME="$4"
NETWORK_NAME="$5"
CHANNEL_NAME="$6"
NUMBER_OF_PEERS="$7"

scp -i ./HLFSaaS.pem  -r ubuntu@${BASE_IP}:/home/ubuntu/nec-network-base/channel-artifacts .
scp -i ./HLFSaaS.pem  -r ubuntu@${BASE_IP}:/home/ubuntu/nec-network-base/crypto-config .

./create-ca-compose.sh $ORG_NAME $DOMAIN_NAME $NETWORK_NAME
sleep 12

./create-crypto.sh $ORG_NAME $DOMAIN_NAME $NETWORK_NAME 0 $NUMBER_OF_PEERS

#. create-ca-compose.sh

#export PATH=${PWD}/bin:$PATH

#createorg $ORG_NAME $DOMAIN_NAME


mkdir ${ORG_NAME}-config
cd ${ORG_NAME}-config

cat << EOF > configtx.yaml

  Organizations:
    - &${ORG_NAME}
      Name: ${ORG_NAME}
      ID: ${ORG_NAME}MSP
      MSPDir: ../crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp
      # Policies: &${ORG_NAME}Policies
      Policies:
            Readers:
                Type: Signature
                Rule: "OR('${ORG_NAME}MSP.admin', '${ORG_NAME}MSP.peer', '${ORG_NAME}MSP.client')"
            Writers:
                Type: Signature
                Rule: "OR('${ORG_NAME}MSP.admin', '${ORG_NAME}MSP.client')"
            Admins:
                Type: Signature
                Rule: "OR('${ORG_NAME}MSP.admin')"
            Endorsement:
                Type: Signature
                Rule: "OR('${ORG_NAME}MSP.peer')"
      AnchorPeers:
          - Host: peer0.${ORG_NAME}.${DOMAIN_NAME}.com
            Port: 7051

EOF
cd ../yamlEditors/
npm install
cd ../${ORG_NAME}-config
node ../yamlEditors/configtxeditor2.js ${ORG_NAME} ${NUMBER_OF_PEERS} ${DOMAIN_NAME} ${NETWORK_NAME}
#../bin/cryptogen generate --config=${ORG_NAME}-crypto.yaml --output="../crypto-config"



export FABRIC_CFG_PATH=$PWD
../bin/configtxgen -printOrg ${ORG_NAME} > ../crypto-config/peerOrganizations/${ORG_NAME}.$DOMAIN_NAME.com/${ORG_NAME}.json


cd ..
docker-compose -f ./docker-compose-$ORG_NAME.yaml up -d



docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${BASE_ORG}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto/peerOrganizations/${BASE_ORG}.$DOMAIN_NAME.com/peers/peer0.$BASE_ORG.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$BASE_ORG.$DOMAIN_NAME.com/users/Admin@$BASE_ORG.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$BASE_ORG.$DOMAIN_NAME.com:7051" cli  peer channel fetch config /var/hyperledger/channel-artifacts/config_block.pb -o orderer.$DOMAIN_NAME.com:7050 --ordererTLSHostnameOverride orderer.$DOMAIN_NAME.com -c $CHANNEL_NAME --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/tlscacerts/tlsca.$DOMAIN_NAME.com-cert.pem"

docker cp cli:/var/hyperledger/channel-artifacts/config_block.pb ./channel-artifacts

cd channel-artifacts

../bin/configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq .data.data[0].payload.data.config config_block.json > config.json


jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"'${ORG_NAME}'MSP":.[1]}}}}}' config.json ../crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/$ORG_NAME.json > modified_config.json


../bin/configtxlator proto_encode --input config.json --type common.Config --output config.pb

../bin/configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb


../bin/configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output ${ORG_NAME}_update.pb

../bin/configtxlator proto_decode --input ${ORG_NAME}_update.pb --type common.ConfigUpdate --output ${ORG_NAME}_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat ${ORG_NAME}_update.json)'}}}' | jq . > ${ORG_NAME}_update_in_envelope.json


../bin/configtxlator proto_encode --input ${ORG_NAME}_update_in_envelope.json --type common.Envelope --output ${ORG_NAME}_update_in_envelope.pb

docker cp ${ORG_NAME}_update_in_envelope.pb cli:/var/hyperledger/channel-artifacts


docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${BASE_ORG}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$BASE_ORG.$DOMAIN_NAME.com/peers/peer0.$BASE_ORG.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$BASE_ORG.$DOMAIN_NAME.com/users/Admin@$BASE_ORG.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$BASE_ORG.$DOMAIN_NAME.com:7051" cli  peer channel update -f /var/hyperledger/channel-artifacts/${ORG_NAME}_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.$DOMAIN_NAME.com:7050 --ordererTLSHostnameOverride orderer.$DOMAIN_NAME.com --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/tlscacerts/tlsca.$DOMAIN_NAME.com-cert.pem"





echo " +++++++++++++++++++++++++++ ANCHOR PEER UPDATION ++++++++++++++++++++++++++"


docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${BASE_ORG}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto/peerOrganizations/${BASE_ORG}.$DOMAIN_NAME.com/peers/peer0.$BASE_ORG.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$BASE_ORG.$DOMAIN_NAME.com/users/Admin@$BASE_ORG.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$BASE_ORG.$DOMAIN_NAME.com:7051" cli  peer channel fetch config /var/hyperledger/channel-artifacts/config_block.pb -o orderer.$DOMAIN_NAME.com:7050 --ordererTLSHostnameOverride orderer.$DOMAIN_NAME.com -c $CHANNEL_NAME --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/tlscacerts/tlsca.$DOMAIN_NAME.com-cert.pem"

docker cp cli:/var/hyperledger/channel-artifacts/config_block.pb ./channel-artifacts


../bin/configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json

jq .data.data[0].payload.data.config config_block.json > config.json

jq '.channel_group.groups.Application.groups.'${ORG_NAME}'MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.'$ORG_NAME'.'$DOMAIN_NAME'.com","port": 7051}]},"version": "0"}}' config.json > modified_anchor_config.json

../bin/configtxlator proto_encode --input config.json --type common.Config --output config.pb

../bin/configtxlator proto_encode --input modified_anchor_config.json --type common.Config --output modified_anchor_config.pb

../bin/configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_anchor_config.pb --output anchor_update.pb

../bin/configtxlator proto_decode --input anchor_update.pb --type common.ConfigUpdate --output anchor_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat anchor_update.json)'}}}' | jq . > anchor_update_in_envelope.json


../bin/configtxlator proto_encode --input anchor_update_in_envelope.json --type common.Envelope --output anchor_update_in_envelope.pb

docker cp anchor_update_in_envelope.pb cli:/var/hyperledger/channel-artifacts


docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp" -e "CORE_PEER_ADDRESS=peer0.$ORG_NAME.$DOMAIN_NAME.com:7051" cli  peer channel update -f /var/hyperledger/channel-artifacts/anchor_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.$DOMAIN_NAME.com:7050 --ordererTLSHostnameOverride orderer.$DOMAIN_NAME.com --tls --cafile "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/tlscacerts/tlsca.$DOMAIN_NAME.com-cert.pem"



rm config.json config.pb
rm config_block.json config_block.pb
rm modified_config.json modified_config.pb
rm ${ORG_NAME}_update.json ${ORG_NAME}_update.pb
rm ${ORG_NAME}_update_in_envelope.json ${ORG_NAME}_update_in_envelope.pb

cd ..

./join-channel.sh ${ORG_NAME} $DOMAIN_NAME $CHANNEL_NAME $NUMBER_OF_PEERS

./startExplorer.sh ${ORG_NAME} $DOMAIN_NAME $NETWORK_NAME $CHANNEL_NAME

./SDKup.sh ${ORG_NAME} ${DOMAIN_NAME} ${NETWORK_NAME} ${CHANNEL_NAME} ${NUMBER_OF_PEERS}


scp -i ./HLFSaaS.pem  -r ./crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com ubuntu@${BASE_IP}:/home/ubuntu/nec-network-base/crypto-config/peerOrganizations

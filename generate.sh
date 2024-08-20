#!/bin/bash


function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31mUsage: \e[0m"
  echo -e "\e[32m\e[1mgenerate.sh [<org name>] [<domain name> ] [<network name>] [<channel name>] "
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
NUMBER_OF_ORDERERS="$5"
NUMBER_OF_PEERS="$6"


cat << EOF > ./configtx.yaml
Organizations:
    - &OrdererOrg
        Name: OrdererOrg
        ID: OrdererMSP
        MSPDir: crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/msp
        Policies:
            Readers:
                Type: Signature
                Rule: "OR('OrdererMSP.member')"
            Writers:
                Type: Signature
                Rule: "OR('OrdererMSP.member')"
            Admins:
                Type: Signature
                Rule: "OR('OrdererMSP.admin')"

    - &${ORG_NAME}
        Name: ${ORG_NAME}MSP
        ID: ${ORG_NAME}MSP
        MSPDir: crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp
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
            # CustomPolicy:
            #     Type: Signature
            #     Rule: "OR('${ORG_NAME}MSP.admin', '${ORG_NAME}MSP.client')"

        AnchorPeers:
            - Host: peer0.${ORG_NAME}.${DOMAIN_NAME}.com
              Port: 7051

    

Capabilities:
    Channel: &ChannelCapabilities
        V2_0: true
    Orderer: &OrdererCapabilities
        V2_0: true
    Application: &ApplicationCapabilities
        V2_0: true

Application: &ApplicationDefaults
    ACLs: &ACLsDefault
        # This section provides defaults for policies for various resources
        # in the system. These "resources" could be functions on system chaincodes
        # (e.g., "GetBlockByNumber" on the "qscc" system chaincode) or other resources
        # (e.g.,who can receive Block events). This section does NOT specify the resource's
        # definition or API, but just the ACL policy for it.
        #
        # User's can override these defaults with their own policy mapping by defining the
        # mapping under ACLs in their channel definition

        #---New Lifecycle System Chaincode (_lifecycle) function to policy mapping for access control--#

        # ACL policy for _lifecycle's "CommitChaincodeDefinition" function
        _lifecycle/CommitChaincodeDefinition: /Channel/Application/Writers

        # ACL policy for _lifecycle's "QueryChaincodeDefinition" function
        _lifecycle/QueryChaincodeDefinition: /Channel/Application/Readers

        # ACL policy for _lifecycle's "QueryNamespaceDefinitions" function
        _lifecycle/QueryNamespaceDefinitions: /Channel/Application/Readers

        #---Lifecycle System Chaincode (lscc) function to policy mapping for access control---#

        # ACL policy for lscc's "getid" function
        lscc/ChaincodeExists: /Channel/Application/Readers

        # ACL policy for lscc's "getdepspec" function
        lscc/GetDeploymentSpec: /Channel/Application/Readers

        # ACL policy for lscc's "getccdata" function
        lscc/GetChaincodeData: /Channel/Application/Readers

        # ACL Policy for lscc's "getchaincodes" function
        lscc/GetInstantiatedChaincodes: /Channel/Application/Readers

        #---Query System Chaincode (qscc) function to policy mapping for access control---#

        # ACL policy for qscc's "GetChainInfo" function
        qscc/GetChainInfo: /Channel/Application/Readers

        # ACL policy for qscc's "GetBlockByNumber" function
        qscc/GetBlockByNumber: /Channel/Application/Readers

        # ACL policy for qscc's  "GetBlockByHash" function
        qscc/GetBlockByHash: /Channel/Application/Readers

        # ACL policy for qscc's "GetTransactionByID" function
        qscc/GetTransactionByID: /Channel/Application/Readers
        # qscc/GetTransactionByID: /Channel/Application/CustomPolicy

        # ACL policy for qscc's "GetBlockByTxID" function
        qscc/GetBlockByTxID: /Channel/Application/Readers

        #---Configuration System Chaincode (cscc) function to policy mapping for access control---#

        # ACL policy for cscc's "GetConfigBlock" function
        cscc/GetConfigBlock: /Channel/Application/Readers

        # ACL policy for cscc's "GetConfigTree" function
        cscc/GetConfigTree: /Channel/Application/Readers

        # ACL policy for cscc's "SimulateConfigTreeUpdate" function
        cscc/SimulateConfigTreeUpdate: /Channel/Application/Readers

        #---Miscellanesous peer function to policy mapping for access control---#

        # ACL policy for invoking chaincodes on peer
        peer/Propose: /Channel/Application/Writers
        # peer/Propose: /Channel/Application/Restrict

        # ACL policy for chaincode to chaincode invocation
        peer/ChaincodeToChaincode: /Channel/Application/Readers

        #---Events resource to policy mapping for access control###---#

        # ACL policy for sending block events
        event/Block: /Channel/Application/Readers

        # ACL policy for sending filtered block events
        event/FilteredBlock: /Channel/Application/Readers


    Organizations:
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        Endorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        # Restrict:
        #     Type: ImplicitMeta
        #     Rule: "ANY CustomPolicy"

    Capabilities:
        <<: *ApplicationCapabilities

Orderer: &OrdererDefaults

    OrdererType: etcdraft

    EtcdRaft:
        Consenters:
        - Host: orderer.${DOMAIN_NAME}.com
          Port: 7050
          ClientTLSCert: crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/tls/server.crt
          ServerTLSCert: crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/tls/server.crt

    Addresses:
        - orderer.${DOMAIN_NAME}.com:7050

    BatchTimeout: 2s

    BatchSize:
        MaxMessageCount: 10
        AbsoluteMaxBytes: 99 MB
        PreferredMaxBytes: 512 KB

    Organizations:

    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
        BlockValidation:
            Type: ImplicitMeta
            Rule: "ANY Writers"

Channel: &ChannelDefaults
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"

    Capabilities:
        <<: *ChannelCapabilities


Profiles:
    NecChannel:
        Consortium: SampleConsortium
        <<: *ChannelDefaults
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - *${ORG_NAME}
            Capabilities:
                <<: *ApplicationCapabilities
    NecOrdererGenesis:
        <<: *ChannelDefaults
        Capabilities:
            <<: *ChannelCapabilities
        Orderer:
            <<: *OrdererDefaults
            OrdererType: etcdraft
            EtcdRaft:
                Consenters:
                - Host: orderer.${DOMAIN_NAME}.com
                  Port: 7050
                  ClientTLSCert: crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/tls/server.crt
                  ServerTLSCert: crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer.${DOMAIN_NAME}.com/tls/server.crt
                - Host: orderer2.${DOMAIN_NAME}.com
                  Port: 7050
                  ClientTLSCert: crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${DOMAIN_NAME}.com/tls/server.crt
                  ServerTLSCert: crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${DOMAIN_NAME}.com/tls/server.crt
                - Host: orderer3.${DOMAIN_NAME}.com
                  Port: 7050
                  ClientTLSCert: crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer3.${DOMAIN_NAME}.com/tls/server.crt
                  ServerTLSCert: crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer3.${DOMAIN_NAME}.com/tls/server.crt
            Addresses:
                - orderer.${DOMAIN_NAME}.com:7050
                - orderer2.${DOMAIN_NAME}.com:7050
                - orderer3.${DOMAIN_NAME}.com:7050

            Organizations:
            - *OrdererOrg
            Capabilities:
                <<: *OrdererCapabilities
        Consortiums:
            SampleConsortium:
                Organizations:
                - *${ORG_NAME}
                
EOF

cat << EOF > ./base/docker-compose-base.yaml
   # Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

version: '2'


services:
  peer-base:
    image: hyperledger/fabric-peer:2.2.2
    environment:
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      # the following setting starts chaincode containers on the same
      # bridge network as the peers
      # https://docs.docker.com/compose/networking/
      - CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=$NETWORK_NAME
      - FABRIC_LOGGING_SPEC=INFO
      #- FABRIC_LOGGING_SPEC=DEBUG
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_GOSSIP_USELEADERELECTION=true
      - CORE_PEER_LISTENADDRESS=0.0.0.0:7051
      - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
      - CORE_PEER_GOSSIP_ORGLEADER=false
      - CORE_PEER_PROFILE_ENABLED=true
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
      # Allow more time for chaincode container to build on install.
      # - CORE_CHAINCODE_EXECUTETIMEOUT=300s
      - CORE_LEDGER_STATE_STATEDATABASE=CouchDB
      - CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
      - CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: peer node start

  orderer-base:
    image: hyperledger/fabric-orderer:2.2.2
    environment:
      - FABRIC_LOGGING_SPEC=INFO
      - ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
      - ORDERER_GENERAL_BOOTSTRAPMETHOD=file
      - ORDERER_GENERAL_BOOTSTRAPFILE=/var/hyperledger/orderer/orderer.genesis.block
      - ORDERER_GENERAL_LOCALMSPID=OrdererMSP
      - ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp
      # enabled TLS
      - ORDERER_GENERAL_TLS_ENABLED=true
      - ORDERER_GENERAL_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      - ORDERER_GENERAL_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      - ORDERER_GENERAL_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
      - ORDERER_TLS_CLIENTROOTCAS_FILES=/var/hyperledger/orderer/users/Admin@$DOMAIN_NAME.com/tls/ca.crt
      - ORDERER_TLS_CLIENTCERT_FILE=/var/hyperledger/orderer/users/Admin@$DOMAIN_NAME.com/tls/client.crt
      - ORDERER_TLS_CLIENTKEY_FILE=/var/hyperledger/orderer/users/Admin@$DOMAIN_NAME.com/tls/client.key
      # - ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR=1
      # - ORDERER_KAFKA_VERBOSE=true
      - ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      - ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      - ORDERER_GENERAL_CLUSTER_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric
    command: orderer
EOF


cd yamlEditors

npm install

node configtxeditor.js $ORG_NAME $NUMBER_OF_ORDERERS $NUMBER_OF_PEERS $DOMAIN_NAME $NETWORK_NAME

cd ..


echo " $ORG_NAME $DOMAIN_NAME $NETWORK_NAME $CHANNEL_NAME "

echo "--------------------- GENERATING CRYPTO----------------------------------"

#./bin/cryptogen generate --config=./crypto-config.yaml --output="crypto-config"

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


export FABRIC_CFG_PATH=$PWD

echo "--------------------- GENERATING GENESIS BLOCK----------------------------------"

mkdir channel-artifacts

./bin/configtxgen -profile NecOrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


echo "--------------------- GENERATING CHANNEL  TRANSACTION----------------------------------"

 ./bin/configtxgen -profile NecChannel -outputCreateChannelTx ./channel-artifacts/$CHANNEL_NAME.tx -channelID $CHANNEL_NAME

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


echo "--------------------- GENERATING ANCHOR PEER FOR $ORG_NAME----------------------------------"

./bin/configtxgen -profile NecChannel -outputAnchorPeersUpdate ./channel-artifacts/${ORG_NAME}MSPanchors.tx -channelID $CHANNEL_NAME -asOrg ${ORG_NAME}MSP

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


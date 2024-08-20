#!/bin/bash

function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31mUsage: \e[0m"
  echo -e "\e[32m\e[1mcreate-compose-ca.sh [<org name>] [<domain name> ] [<network name>]  "
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
cat << EOF > docker-compose-ca.yaml

# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

version: '2'

networks:
  default:
     external:
         name: $NETWORK_NAME

services:

  ca_${ORG_NAME}:
    image: hyperledger/fabric-ca:latest
    labels:
      service: hyperledger-fabric
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_CA_NAME=ca-$ORG_NAME
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_PORT=8054
      - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:18054
    ports:
      - "8054:8054"
      - "18054:18054"
    command: sh -c 'fabric-ca-server start -b admin:adminpw -d'
    volumes:
      - ./crypto-config/fabric-ca/$ORG_NAME:/etc/hyperledger/fabric-ca-server
    container_name: ca_$ORG_NAME

  ca_orderer:
    image: hyperledger/fabric-ca:latest
    labels:
      service: hyperledger-fabric
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_CA_NAME=ca-orderer
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_PORT=9054
      - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:19054
    ports:
      - "9054:9054"
      - "19054:19054"
    command: sh -c 'fabric-ca-server start -b admin:adminpw -d'
    volumes:
      - ./crypto-config/fabric-ca/ordererOrg:/etc/hyperledger/fabric-ca-server
    container_name: ca_orderer

EOF

mkdir -p ./crypto-config/fabric-ca

sleep 10


docker-compose -f ./docker-compose-ca.yaml up -d





function createOrderer() {

  DOMAIN_NAME="$1"
  NUMBER_OF_ORDERERS="$2"  
  echo  "Enrolling the CA admin"
   mkdir -p crypto-config/ordererOrganizations/$DOMAIN_NAME.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/crypto-config/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null	  

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/msp/config.yaml


   

  	  
  echo "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/crypto-config/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  for (( i=1; i<=$NUMBER_OF_ORDERERS; i++ )) do

 if [ $i == 1 ]
  then	   
   echo "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/crypto-config/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null
  	  
  echo "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp --csr.hosts orderer.$DOMAIN_NAME.com --csr.hosts localhost --tls.certfiles ${PWD}/crypto-config/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/config.yaml

  echo "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/tls --enrollment.profile tls --csr.hosts orderer.$DOMAIN_NAME.com --csr.hosts localhost --tls.certfiles ${PWD}/crypto-config/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/tls/ca.crt
  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/tls/signcerts/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/tls/server.crt
  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/tls/keystore/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/tls/server.key
 
 else
  echo "Registering orderer$i"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer$i --id.secret orderer${i}pw --id.type orderer --tls.certfiles ${PWD}/crypto-config/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "Generating the orderer$i msp"
  set -x
  fabric-ca-client enroll -u https://orderer$i:orderer${i}pw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer${i}.$DOMAIN_NAME.com/msp --csr.hosts orderer{$i}.$DOMAIN_NAME.com --csr.hosts localhost --tls.certfiles ${PWD}/crypto-config/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null
  sleep 8
  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer${i}.$DOMAIN_NAME.com/msp/config.yaml

  echo "Generating the orderer$i-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer${i}:orderer${i}pw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer${i}.$DOMAIN_NAME.com/tls --enrollment.profile tls --csr.hosts orderer${i}.$DOMAIN_NAME.com --csr.hosts localhost --tls.certfiles ${PWD}/crypto-config/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null
  
  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer${i}.$DOMAIN_NAME.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer${i}.$DOMAIN_NAME.com/tls/ca.crt
  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer${i}.$DOMAIN_NAME.com/tls/signcerts/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer${i}.$DOMAIN_NAME.com/tls/server.crt
  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer${i}.$DOMAIN_NAME.com/tls/keystore/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer${i}.$DOMAIN_NAME.com/tls/server.key

 fi
done 




  mkdir -p ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/tlscacerts
  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/msp/tlscacerts/tlsca.$DOMAIN_NAME.com-cert.pem

  mkdir -p ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/msp/tlscacerts
  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/orderers/orderer.$DOMAIN_NAME.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/msp/tlscacerts/tlsca.$DOMAIN_NAME.com-cert.pem

  echo "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/users/Admin@$DOMAIN_NAME.com/msp --tls.certfiles ${PWD}/crypto-config/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_NAME.com/users/Admin@$DOMAIN_NAME.com/msp/config.yaml
}


function createorg() {

   ORG_NAME="$1"
   DOMAIN_NAME="$2"
   NUMBER_OF_PEERS="$3"   
  echo "Enrolling the CA admin"
  mkdir -p crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-$ORG_NAME --tls.certfiles ${PWD}/crypto-config/fabric-ca/$ORG_NAME/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-'${ORG_NAME}'.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-'${ORG_NAME}'.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-'${ORG_NAME}'.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-'${ORG_NAME}'.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/msp/config.yaml



  sleep 20  

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-$ORG_NAME --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/crypto-config/fabric-ca/$ORG_NAME/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-$ORG_NAME --id.name ${ORG_NAME}admin --id.secret ${ORG_NAME}adminpw --id.type admin --tls.certfiles ${PWD}/crypto-config/fabric-ca/$ORG_NAME/tls-cert.pem
  { set +x; } 2>/dev/null

  for ((i=0; i<$NUMBER_OF_PEERS; i++ ))
  do
   echo "Registering peer${i}"
  set -x
  fabric-ca-client register --caname ca-$ORG_NAME --id.name peer${i} --id.secret peer${i}pw --id.type peer --tls.certfiles ${PWD}/crypto-config/fabric-ca/$ORG_NAME/tls-cert.pem
  { set +x; } 2>/dev/null


  echo "Generating the peer${i} msp"
  set -x
  fabric-ca-client enroll -u https://peer${i}:peer${i}pw@localhost:8054 --caname ca-$ORG_NAME -M ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer${i}.$ORG_NAME.$DOMAIN_NAME.com/msp --csr.hosts peer${i}.$ORG_NAME.$DOMAIN_NAME.com --tls.certfiles ${PWD}/crypto-config/fabric-ca/$ORG_NAME/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer${i}.$ORG_NAME.$DOMAIN_NAME.com/msp/config.yaml

  echo "Generating the peer${i}-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer${i}:peer${i}pw@localhost:8054 --caname ca-$ORG_NAME -M ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer${i}.$ORG_NAME.$DOMAIN_NAME.com/tls --enrollment.profile tls --csr.hosts peer${i}.$ORG_NAME.$DOMAIN_NAME.com --csr.hosts localhost --tls.certfiles ${PWD}/crypto-config/fabric-ca/$ORG_NAME/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer${i}.$ORG_NAME.$DOMAIN_NAME.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer${i}.$ORG_NAME.$DOMAIN_NAME.com/tls/ca.crt
  cp ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer${i}.$ORG_NAME.$DOMAIN_NAME.com/tls/signcerts/* ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer${i}.$ORG_NAME.$DOMAIN_NAME.com/tls/server.crt
  cp ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer${i}.$ORG_NAME.$DOMAIN_NAME.com/tls/keystore/* ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer${i}.$ORG_NAME.$DOMAIN_NAME.com/tls/server.key
  done
  mkdir -p ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/msp/tlscacerts
  cp ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/tlsca
  cp ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/tlsca/tlsca.$ORG_NAME.$DOMAIN_NAME.com-cert.pem

  mkdir -p ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/ca
  cp ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/peers/peer0.$ORG_NAME.$DOMAIN_NAME.com/msp/cacerts/* ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/ca/ca.$ORG_NAME.$DOMAIN_NAME.com-cert.pem


  


 
  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-$ORG_NAME -M ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/User1@$ORG_NAME.$DOMAIN_NAME.com/msp --tls.certfiles ${PWD}/crypto-config/fabric-ca/$ORG_NAME/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/User1@$ORG_NAME.$DOMAIN_NAME.com/msp/config.yaml

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://${ORG_NAME}admin:${ORG_NAME}adminpw@localhost:8054 --caname ca-$ORG_NAME -M ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp --tls.certfiles ${PWD}/crypto-config/fabric-ca/$ORG_NAME/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/users/Admin@$ORG_NAME.$DOMAIN_NAME.com/msp/config.yaml
}


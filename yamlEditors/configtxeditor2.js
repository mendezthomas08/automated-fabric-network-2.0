 /*eslint-disable no-console*/
 var fs = require("fs");
 var path = require("path");
 var util = require("util");
 var yaml = require("js-yaml");
 const YAML = require('json-to-pretty-yaml');
 //Attention. this script requires 2 args as input==> orgname and domain name
 const args = process.argv;
 var orgName = args[2];
// var numberOfOrderers = args[3]
 var numberOfPeers = args[3]
 var domainName = args[4]
 var networkName = args[5]

 try {



 var dockercompose = {
    "version": "2",
    "volumes": {

    },
    "networks": {
      "default": {
        "external": {
          "name": `${networkName}`
        }
      }
    },
    "services": {


      "cli": {
        "container_name": "cli",
        "image": "hyperledger/fabric-tools",
        "tty": true,
        "stdin_open": true,
        "environment": [
          "GOPATH=/opt/gopath",
          "CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock",
          "FABRIC_LOGGING_SPEC=ERROR",
          "CORE_PEER_TLS_ENABLED=true",
          "CORE_PEER_ID=cli",
          `CORE_PEER_MSPCONFIGPATH=${networkName}`,
          `CORE_PEER_LOCALMSPID=${orgName}MSP`,
          `CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}.com/peers/peer0.${orgName}.${domainName}.com/tls/server.crt`,
          `CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}.com/peers/peer0.${orgName}.${domainName}.com/tls/server.key`,
          `CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}.com/users/Admin@${orgName}.${domainName}.com/msp`,
          `CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}.com/peers/peer0.${orgName}.${domainName}.com/tls/ca.crt`,
          `CORE_CHAINCODE_KEEPALIVE=10`
        ],
        "working_dir": "/opt/gopath/src/github.com/hyperledger/fabric/peer",
        "command": "/bin/bash",
        "volumes": [
          "/var/run/:/host/var/run/",
          "./crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto",
          "./chaincode:/opt/gopath/src/github.com/hyperledger/fabric/peer/chaincode",
          "./channel-artifacts:/var/hyperledger/channel-artifacts"
        ],
        "depends_on": [

        ]
      }
    }
  }

  let coudbPort = 5984
  let peerPort = 7051
  let peerPort2 = 7052
  let peerPort3 = 7053
  for (let i=0;i<numberOfPeers;i++){

     var couchdbService = {
        "container_name": `couchdb${i}${orgName}`,
        "image": "hyperledger/fabric-couchdb",
        "environment": [
          "COUCHDB_USER=",
          "COUCHDB_PASSWORD="
        ],
        "ports": [
          `${coudbPort}:5984`
        ],
        "volumes": [
          `./persist/couchdb${i}${orgName}:/opt/couchdb/data`
        ]
      }
     var peerServices = {
        "container_name": `peer${i}.${orgName}.${domainName}.com`,
        "extends": {
          "file": "base/docker-compose-base.yaml",
          "service": "peer-base"
        },
        "environment": [
          `CORE_PEER_ID=peer${i}.${orgName}.${domainName}.com`,
          `CORE_PEER_ADDRESS=peer${i}.${orgName}.${domainName}.com:7051`,
          `CORE_PEER_CHAINCODEADDRESS=peer${i}.${orgName}.${domainName}.com:7052`,
          `CORE_PEER_LOCALMSPID=${orgName}MSP`,
          `CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer${i}.${orgName}.${domainName}.com:7051`,
          `CORE_PEER_GOSSIP_BOOTSTRAP=peer${i}.${orgName}.${domainName}.com:7051`,
          `CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb${i}${orgName}:5984`
        ],
        "volumes": [
          "/var/run/:/host/var/run/",
          `./crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto`,
          `./crypto-config/ordererOrganizations/${domainName}.com/users:/var/hyperledger/users`,
          `./crypto-config/peerOrganizations/${orgName}.${domainName}.com/peers/peer${i}.${orgName}.${domainName}.com/msp:/etc/hyperledger/fabric/msp`,
          `./crypto-config/peerOrganizations/${orgName}.${domainName}.com/peers/peer${i}.${orgName}.${domainName}.com/tls:/etc/hyperledger/fabric/tls`,
          `./containers/peer${i}.${orgName}.${domainName}.com:/var/hyperledger/production`,
          `./chaincode:/opt/gopath/src/github.com/hyperledger/fabric/peer/chaincode`,
          `./channel-artifacts:/var/hyperledger/channel-artifacts`
        ],
        "depends_on": [
          `couchdb${i}${orgName}`
        ],
        "ports": [
          `${peerPort}:7051`,
          `${peerPort2}:7052`,
          `${peerPort3}:7053`
        ]
      }
    dockercompose.volumes[`peer${i}.${orgName}.${domainName}.com`] = null
    dockercompose.services[`couchdb${i}${orgName}`] = couchdbService
    dockercompose.services[`peer${i}.${orgName}.${domainName}.com`] = peerServices
    dockercompose.services.cli.depends_on.push(`peer${i}.${orgName}.${domainName}.com`)
    coudbPort+=1000
    peerPort+=10
    peerPort2+=10
    peerPort3+=10
  }
   //const configtx = YAML.stringify(configtxjson);
   const dockercomposejson = YAML.stringify(dockercompose);
   //console.log(configtx)
   //console.log("##########################&&&&&&&&&&&&&&&&&&&&&&&&&&")
   //console.log(dockercomposejson)
   //fs.writeFile("../configtx.yaml", configtx, "utf8", err => {
   // if (err) console.log(err);
  //});
  fs.writeFile(`../docker-compose-${orgName}.yaml`, dockercomposejson, "utf8", err => {
    if (err) console.log(err);
  });
 } catch (err) {
   console.log(err.stack || String(err));
 }

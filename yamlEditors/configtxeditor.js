 /*eslint-disable no-console*/
 var fs = require("fs");
 var path = require("path");
 var util = require("util");
 var yaml = require("js-yaml");
 const YAML = require('json-to-pretty-yaml');
 //Attention. this script requires 2 args as input==> orgname and domain name
 const args = process.argv;
 var orgName = args[2];
 var numberOfOrderers = args[3]
 var numberOfPeers = args[4]
 var domainName = args[5]
 var networkName = args[6]
 
 try {
 
//      var configtxjson = {
//    "Capabilities": {
//      "Application": {
//        "V2_0": true
//      },
//      "Orderer": {
//        "V2_0": true
//      },
//      "Channel": {
//        "V2_0": true
//      }
//    },
//    "Organizations": [
//      {
//        "Name": "OrdererMSP",
//        "ID": "OrdererMSP",
//        "MSPDir": `./crypto-config/ordererOrganizations/${domainName}.com/msp`,
//        "Policies": {
//          "Readers": {
//            "Type": "Signature",
//            "Rule": "OR('OrdererMSP.member')"
//          },
//          "Writers": {
//            "Type": "Signature",
//            "Rule": "OR('OrdererMSP.member')"
//          },
//          "Admins": {
//            "Type": "Signature",
//            "Rule": "OR('OrdererMSP.admin')"
//          }
//        }
//      }
     
//    ],
//    "Orderer": {
//      "OrdererType": "etcdraft",
//      "Addresses": [
       
//      ],
//      "EtcdRaft": {
//        "Consenters": [
         
//        ]
//      },
//      "Policies": {
//        "Readers": {
//          "Type": "ImplicitMeta",
//          "Rule": "ANY Readers"
//        },
//        "Writers": {
//          "Type": "ImplicitMeta",
//          "Rule": "ANY Writers"
//        },
//        "Admins": {
//          "Type": "ImplicitMeta",
//          "Rule": "ANY Admins"
//        },
//        "BlockValidation": {
//          "Type": "ImplicitMeta",
//          "Rule": "ANY Writers"
//        }
//      },
//      "BatchTimeout": "2s",
//      "BatchSize": {
//        "MaxMessageCount": 10,
//        "AbsoluteMaxBytes": "98 MB",
//        "PreferredMaxBytes": "512 KB"
//      },
//      "Capabilities": {
//        "V2_0": true
//      }
//    },
//    "Application": {
//      "Policies": {
//        "Endorsement": {
//          "Type": "ImplicitMeta",
//          "Rule": "MAJORITY Endorsement"
//        },
//        "LifecycleEndorsement": {
//         "Type": "ImplicitMeta",
//         "Rule": "MAJORITY Endorsement"
//       },
//        "Readers": {
//          "Type": "ImplicitMeta",
//          "Rule": "ANY Readers"
//        },
//        "Writers": {
//          "Type": "ImplicitMeta",
//          "Rule": "ANY Writers"
//        },
//        "Admins": {
//          "Type": "ImplicitMeta",
//          "Rule": "ANY Admins"
//        }
//      },
//      "Capabilities": {
//        "V2_0": true
//      },
//      "Organizations": null
//    },
//    "Channel": {
//      "Policies": {
//        "Readers": {
//          "Type": "ImplicitMeta",
//          "Rule": "ANY Readers"
//        },
//        "Writers": {
//          "Type": "ImplicitMeta",
//          "Rule": "ANY Writers"
//        },
//        "Admins": {
//          "Type": "ImplicitMeta",
//          "Rule": "ANY Admins"
//        }
//      },
//      "Capabilities": {
//        "V2_0": true
//      }
//    },
//    "Profiles": {
//      "NecOrdererGenesis": {
//        "Policies": {
//          "Readers": {
//            "Type": "ImplicitMeta",
//            "Rule": "ANY Readers"
//          },
//          "Writers": {
//            "Type": "ImplicitMeta",
//            "Rule": "ANY Writers"
//          },
//          "Admins": {
//            "Type": "ImplicitMeta",
//            "Rule": "ANY Admins"
//          }
//        },
//        "Capabilities": {
//          "V2_0": true
//        },
//        "Orderer": {
//          "OrdererType": "etcdraft",
//          "Addresses": [
           
//          ],
//          "EtcdRaft": {
//            "Consenters": [
             
//            ]
//          },
//          "Policies": {
//            "Readers": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Readers"
//            },
//            "Writers": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Writers"
//            },
//            "Admins": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Admins"
//            },
//            "BlockValidation": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Writers"
//            }
//          },
//          "BatchTimeout": "2s",
//          "BatchSize": {
//            "MaxMessageCount": 10,
//            "AbsoluteMaxBytes": "98 MB",
//            "PreferredMaxBytes": "512 KB"
//          },
//          "Capabilities": {
//            "V2_0": true
//          },
//          "Organizations": [
//            {
//              "Name": "OrdererMSP",
//              "ID": "OrdererMSP",
//              "MSPDir": `./crypto-config/ordererOrganizations/${domainName}.com/msp`,
//              "Policies": {
//                "Readers": {
//                  "Type": "Signature",
//                  "Rule": "OR('OrdererMSP.member')"
//                },
//                "Writers": {
//                  "Type": "Signature",
//                  "Rule": "OR('OrdererMSP.member')"
//                },
//                "Admins": {
//                  "Type": "Signature",
//                  "Rule": "OR('OrdererMSP.admin')"
//                }
//              }
//            }
//          ]
//        },
//        "Consortiums": {
//          "SampleConsortium": {
//            "Organizations": [
            
//            ]
//          }
//        }
//      },
//      "NecChannel": {
//        "Consortium": "NecConsortium",
//        "Policies": {
//          "Readers": {
//            "Type": "ImplicitMeta",
//            "Rule": "ANY Readers"
//          },
//          "Writers": {
//            "Type": "ImplicitMeta",
//            "Rule": "ANY Writers"
//          },
//          "Admins": {
//            "Type": "ImplicitMeta",
//            "Rule": "ANY Admins"
//          }
//        },
//        "Capabilities": {
//          "V2_0": true
//        },
//        "Application": {
//          "Policies": {
//            "Endorsement": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Endorsement"
//            },
//            "Readers": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Readers"
//            },
//            "Writers": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Writers"
//            },
//            "Admins": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Admins"
//            }
//          },
//          "Capabilities": {
//            "V2_0": true
//          },
//          "Organizations": [
           
//          ]
//        }
//      },
//      "NecMultiNodeEtcdRaft": {
//        "Policies": {
//          "Readers": {
//            "Type": "ImplicitMeta",
//            "Rule": "ANY Readers"
//          },
//          "Writers": {
//            "Type": "ImplicitMeta",
//            "Rule": "ANY Writers"
//          },
//          "Admins": {
//            "Type": "ImplicitMeta",
//            "Rule": "ANY Admins"
//          }
//        },
//        "Capabilities": {
//          "V2_0": true
//        },
//        "Orderer": {
//          "OrdererType": "etcdraft",
//          "Addresses": [
           
//          ],
//          "EtcdRaft": {
//            "Consenters": [
             
//            ]
//          },
//          "Policies": {
//            "Readers": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Readers"
//            },
//            "Writers": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Writers"
//            },
//            "Admins": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Admins"
//            },
//            "BlockValidation": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Writers"
//            }
//          },
//          "BatchTimeout": "2s",
//          "BatchSize": {
//            "MaxMessageCount": 10,
//            "AbsoluteMaxBytes": "98 MB",
//            "PreferredMaxBytes": "512 KB"
//          },
//          "Capabilities": {
//            "V2_0": true
//          },
//          "Organizations": [
//            {
//              "Name": "OrdererMSP",
//              "ID": "OrdererMSP",
//              "MSPDir": `./crypto-config/ordererOrganizations/${domainName}.com/msp`,
//              "Policies": {
//                "Readers": {
//                  "Type": "Signature",
//                  "Rule": "OR('OrdererMSP.member')"
//                },
//                "Writers": {
//                  "Type": "Signature",
//                  "Rule": "OR('OrdererMSP.member')"
//                },
//                "Admins": {
//                  "Type": "Signature",
//                  "Rule": "OR('OrdererMSP.admin')"
//                }
//              }
//            }
//          ]
//        },
//        "Application": {
//          "Policies": {
//            "Endorsement": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Endorsement"
//            },
//            "Readers": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Readers"
//            },
//            "Writers": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Writers"
//            },
//            "Admins": {
//              "Type": "ImplicitMeta",
//              "Rule": "ANY Admins"
//            }
//          },
//          "Capabilities": {
//            "V2_0": true
//          },
//          "Organizations": [
//            {
//              "Name": "OrdererMSP",
//              "ID": "OrdererMSP",
//              "MSPDir": `./crypto-config/ordererOrganizations/${domainName}.com/msp`,
//              "Policies": {
//                "Readers": {
//                  "Type": "Signature",
//                  "Rule": "OR('OrdererMSP.member')"
//                },
//                "Writers": {
//                  "Type": "Signature",
//                  "Rule": "OR('OrdererMSP.member')"
//                },
//                "Admins": {
//                  "Type": "Signature",
//                  "Rule": "OR('OrdererMSP.admin')"
//                }
//              }
//            }
//          ]
//        },
//        "Consortiums": {
//          "NecConsortium": {
//            "Organizations": [
             
//            ]
//          }
//        }
//      }
//    }
//  }
 
//   var orgJson = {
//        "Name": `${orgName}`,
//        "ID": `${orgName}MSP`,
//        "MSPDir": `./crypto-config/peerOrganizations/${orgName}.${domainName}.com/msp`,
//        "Policies": {
//          "Readers": {
//            "Type": "Signature",
//            "Rule": `OR('${orgName}MSP.member','${orgName}MSP.admin')`
//          },
//          "Writers": {
//            "Type": "Signature",
//            "Rule": `OR('${orgName}MSP.member','${orgName}MSP.admin')`
//          },
//          "Admins": {
//            "Type": "Signature",
//            "Rule": `OR('${orgName}MSP.admin')`
//          }
//        },
//        "AnchorPeers": [
//          {
//            "Host": "peer0."+ orgName +"." + domainName + ".com",
//            "Port": 7051
//          }
//        ]
//   }
 
//  configtxjson.Organizations.push(orgJson)
//  var ordererAddress  = []
//  var consenters = []
 
//  for (let i = 1; i<=numberOfOrderers; i++){
//     if(i == 1){
//      ordererAddress.push(`orderer.${domainName}.com:7050`)
//      var consenter = {
//                "Host": `orderer.${domainName}.com`,
//                "Port": 7050,
//                "ClientTLSCert": `./crypto-config/ordererOrganizations/${domainName}.com/orderers/orderer.${domainName}.com/tls/server.crt`,
//                "ServerTLSCert": `./crypto-config/ordererOrganizations/${domainName}.com/orderers/orderer.${domainName}.com/tls/server.crt`
//              }
//      consenters.push(consenter)
 
//     }
//     else{
//      ordererAddress.push(`orderer${i}.${domainName}.com:7050`)
//      var consenter = {
//                "Host": `orderer${i}.${domainName}.com`,
//                "Port": 7050,
//                "ClientTLSCert": `./crypto-config/ordererOrganizations/${domainName}.com/orderers/orderer${i}.${domainName}.com/tls/server.crt`,
//                "ServerTLSCert": `./crypto-config/ordererOrganizations/${domainName}.com/orderers/orderer${i}.${domainName}.com/tls/server.crt`
//              }
//      consenters.push(consenter)
//     }
//  }
//  configtxjson.Orderer.Addresses = ordererAddress
//  configtxjson.Orderer.EtcdRaft.Consenters = consenters
//  configtxjson.Profiles.NecOrdererGenesis.Orderer.Addresses = ordererAddress
//  configtxjson.Profiles.NecOrdererGenesis.Orderer.EtcdRaft.Consenters = consenters;
//  configtxjson.Profiles.NecOrdererGenesis.Consortiums.SampleConsortium.Organizations.push(orgJson)
//  configtxjson.Profiles.NecChannel.Application.Organizations.push(orgJson)
//  configtxjson.Profiles.NecMultiNodeEtcdRaft.Orderer.Addresses = ordererAddress
//  configtxjson.Profiles.NecMultiNodeEtcdRaft.Orderer.EtcdRaft.Consenters = consenters
//  configtxjson.Profiles.NecMultiNodeEtcdRaft.Consortiums.NecConsortium.Organizations.push(orgJson)


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
 
  for (let i=1,port = 7050;i<=numberOfOrderers;i++,port += 1000){
    var ordererServices
    
    if(i == 1){
    dockercompose.volumes[`orderer.${domainName}.com`] = null
      ordererServices = {
        "extends": {
          "file": "base/docker-compose-base.yaml",
          "service": "orderer-base"
        },
        "container_name": `orderer.${domainName}.com`,
        "volumes": [
          `./channel-artifacts/genesis.block:/var/hyperledger/orderer/orderer.genesis.block`,
          `./crypto-config/ordererOrganizations/${domainName}.com/orderers/orderer.${domainName}.com/msp:/var/hyperledger/orderer/msp`,
          `./crypto-config/ordererOrganizations/${domainName}.com/orderers/orderer.${domainName}.com/tls:/var/hyperledger/orderer/tls`,
          `./containers/orderer.${domainName}.com:/var/hyperledger/production/orderer`,
          `./chaincode:/opt/gopath/src/github.com/hyperledger/fabric/peer/chaincode`,
          `./channel-artifacts:/var/hyperledger/channel-artifacts`
        ],
        "ports": [
          `${port}:7050`
        ]
      }
      dockercompose.services[`orderer.${domainName}.com.`] = ordererServices
    }
    else{
    dockercompose.volumes[`orderer${i}.${domainName}.com`] = null
    ordererServices = {
        "extends": {
          "file": "base/docker-compose-base.yaml",
          "service": "orderer-base"
        },
        "container_name": `orderer${i}.${domainName}.com`,
        "volumes": [
          `./channel-artifacts/genesis.block:/var/hyperledger/orderer/orderer.genesis.block`,
          `./crypto-config/ordererOrganizations/${domainName}.com/orderers/orderer${i}.${domainName}.com/msp:/var/hyperledger/orderer/msp`,
          `./crypto-config/ordererOrganizations/${domainName}.com/orderers/orderer${i}.${domainName}.com/tls:/var/hyperledger/orderer/tls`,
          `./containers/orderer${i}.${domainName}.com:/var/hyperledger/production/orderer`,
          `./chaincode:/opt/gopath/src/github.com/hyperledger/fabric/peer/chaincode`,
          `./channel-artifacts:/var/hyperledger/channel-artifacts`
        ],
        "ports": [
          `${port}:7050`
        ]
      }
      dockercompose.services[`orderer${i}.${domainName}.com.`] = ordererServices
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
   console.log(dockercomposejson)
  //  fs.writeFile("../configtx.yaml", configtx, "utf8", err => {
  //   if (err) console.log(err);
  // });
  fs.writeFile("../docker-compose.yaml", dockercomposejson, "utf8", err => {
    if (err) console.log(err);
  });
 } catch (err) {
   console.log(err.stack || String(err));
 }
 

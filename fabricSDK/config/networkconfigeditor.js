 /*eslint-disable no-console*/
 var fs = require("fs");
 var path = require("path");
 var util = require("util");
 var yaml = require("js-yaml");
const { exec } = require("child_process");
 const YAML = require('json-to-pretty-yaml');
 //Attention. this script requires 2 args as input==> orgname and domain name
 const args = process.argv;
 var orgName = args[2];
 var domainName = args[3]
 var channelName = args[4]
 var numberOfPeers = args[5]
 
 
 
 try {
 
     var networkconfigjson = {
      "name": "network-config",
      "version": "1.0.0",
      "client": {
          "organization": `${orgName}`,
          "connection": {
              "timeout": {
                  "peer": {
                      "endorser": "300"
                  }
              }
          }
      },
      "organizations": {
          
      },
      "peers": {
          
  
    
      },
      "certificateAuthorities": {
          
      }
  }
  
  var peers = []
  for (let i = 0,port = 7051;i<numberOfPeers;i++,port+=10){
    let peerCaPath = path.join(__dirname, '..', '..', 'crypto-config','peerOrganizations',`${orgName}.${domainName}.com`,'peers',`/peer${i}.${orgName}.${domainName}.com`,'tls','ca.crt')
    let pem =  (fs.readFileSync(peerCaPath,{ encoding: "utf8" })); 	
   	  
    peers.push(`peer${i}.${orgName}.${domainName}.com`)
    networkconfigjson.peers[`peer${i}.${orgName}.${domainName}.com`] = {
      "url": `grpcs://peer${i}.${orgName}.${domainName}.com:7051`,
      "tlsCACerts": {
          "pem": `${pem}`
      },
      "grpcOptions": {
          "ssl-target-name-override": `peer${i}.${orgName}.${domainName}.com`,
          "hostnameOverride": `peer${i}.${orgName}.${domainName}.com`
      }
    }
  }
     networkconfigjson.organizations[`${orgName}`] = {
      "mspid": `${orgName}MSP`,
      "peers": peers, 
      "certificateAuthorities": [
        `ca-${orgName}`
       ]
     } 
    let caPath =  path.join(__dirname, '..', '..', 'crypto-config','peerOrganizations',`${orgName}.${domainName}.com`,`ca`,`ca.${orgName}.${domainName}.com-cert.pem`)
    let caPem =  (fs.readFileSync(caPath,{ encoding: "utf8" }));	 
     networkconfigjson.certificateAuthorities[`ca.${orgName}.${domainName}.com`] = {
      "url": `https://ca_${orgName}:8054`,
      "caName": `ca-${orgName}`,
      "tlsCACerts": {
          "pem": `${caPem}`
      },
      "httpOptions": {
          "verify": false
      }
  }
     
  var config = 
  {
    "host": "localhost",
    "port": "4000",
    "jwt_expiretime": "36000",
    "channelName": `${channelName}`,
    "CC_SRC_PATH": "../..",
    "eventWaitTime": "30000",
    "admins": [
        {
            "username": "admin",
            "secret": "adminpw"
        }
    ]
}
 
 

   //console.log(configtx)
   //console.log("##########################&&&&&&&&&&&&&&&&&&&&&&&&&&")
   //console.log(dockercomposejson)
   fs.writeFile("./network-config.json", JSON.stringify(networkconfigjson), 'utf8', function (err) {
    if (err) {
        console.log("An error occured while writing JSON Object to File.");
        return console.log(err);
    }
 
    console.log("JSON file has been saved.");
});

   fs.writeFile("./config.json", JSON.stringify(config), 'utf8', function (err) {
    if (err) {
        console.log("An error occured while writing JSON Object to File.");
        return console.log(err);
    }
 
    console.log("JSON file has been saved.");
});	 
 } catch (err) {
   console.log(err.stack || String(err));
 }
 

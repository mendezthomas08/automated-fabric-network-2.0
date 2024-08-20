INSTALL PREREQUISITES

step 1: cd automated-fabric-network
step 2 : ./installPreReq.sh
step 3 : Follow the Instructions given by the output of the above script
BRING UP THE NETWORK

 step 1: ./networkUp.sh <ORG_NAME> <DOMAIN_NAME> <NETWORK_NAME> <CHANNEL_NAME> <NUMBER_OF_ORDERERS> <NUMBER_OF_PEERS>

 Replace the placeholder argument with value of your choice
 example: ./network.sh org1 example.com my-network mychannel 3 2

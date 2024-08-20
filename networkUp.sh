#!/bin/bash

function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31mUsage: \e[0m"
  echo -e "\e[32m\e[1mnetworkUp.sh [<ORG_NAME> <DOMAIN_NAME> <NETWORK_NAME> <CHANNEL_NAME> <NUMBER_OF_ORDERERS> <NUMBER_OF_PEERS>] "
  echo -e "\e[35m[<org name>]\e[0m= name of the org\e[0m"
  echo -e "\e[34m#############################################################################################\e[0m"
}

ORG_NAME="$1"
DOMAIN_NAME="$2"
NETWORK_NAME="$3"
CHANNEL_NAME="$4"
NUMBER_OF_ORDERERS="$5"
NUMBER_OF_PEERS="$6"

echo $NETWORK_NAME

docker swarm init

if [ "$#" = 0 ]; then
 printHelp
 exit 1
fi

#read -p "Enter number Of Orderers : " NUMBER_OF_ORDERERS

#read -p "Enter Number Of Peers : " NUMBER_OF_PEERS
re='^[0-9]+$'
if ! [[ $NUMBER_OF_ORDERERS =~ $re ]] ; then
   echo "error: Not a number" >&2; exit 1
fi

if ! [[ $NUMBER_OF_PEERS =~ $re ]] ; then
   echo "error: Not a number" >&2; exit 1
fi

#declare -a ORG_ARRAY

#for (( i=0; i<$n1 ; i++ )) do
#  read -p " Enter organization $i : " ORG_ARRAY[$i]	
#done


echo -e "\e[34m###########################################################\e[0m"
echo -e "\e[32m creating Driver overlay ${NETWORK_NAME}\e[0m"
echo -e "\e[34m###########################################################\e[0m"
docker network create --attachable --driver overlay ${NETWORK_NAME}



./create-ca-compose.sh ${ORG_NAME} $DOMAIN_NAME $NETWORK_NAME

sleep 5

./create-crypto.sh ${ORG_NAME} $DOMAIN_NAME $NETWORK_NAME $NUMBER_OF_ORDERERS $NUMBER_OF_PEERS


./generate.sh ${ORG_NAME} $DOMAIN_NAME $NETWORK_NAME $CHANNEL_NAME $NUMBER_OF_ORDERERS $NUMBER_OF_PEERS

./start.sh ${ORG_NAME} $DOMAIN_NAME $NETWORK_NAME $CHANNEL_NAME $NUMBER_OF_PEERS

#PORT=7071
#k=10
#for (( i=1,PORT=7071 ; i<$n1 ; i++,PORT=$(($PORT + $k )) )) do 
#   ./addNewOrg.sh ${ORG_ARRAY[${i}]} ${ORG_ARRAY[0]} $DOMAIN_NAME $NETWORK_NAME $CHANNEL_NAME $PORT
#   ./join-channel.sh ${ORG_ARRAY[${i}]} $DOMAIN_NAME $CHANNEL_NAME
#done 

#for (( i=0; i<$n1; i++ )) do 
   ./installAndApprove.sh ${ORG_NAME} $DOMAIN_NAME $CHANNEL_NAME ./chaincode/asset/javascript node fabcc_1 fabcc 1.0 1
#done

./startExplorer.sh ${ORG_NAME} $DOMAIN_NAME $NETWORK_NAME $CHANNEL_NAME	


./SDKup.sh ${ORG_NAME} ${DOMAIN_NAME} ${NETWORK_NAME} ${CHANNEL_NAME} ${NUMBER_OF_PEERS}


echo -e "\e[34m############################################################\e[0m"
  echo -e "\e[32m FabricSDK app is up and running on PORT:\e[5m4000 \e[0m\e[32m\e[0m"
  echo -e "\e[34m############################################################\e[0m"

docker swarm join-token manager
#!/bin/bash


function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31mUsage: \e[0m"
  echo -e "\e[32m\e[1mjoin-channel.sh [<org name>] [<domain-name>] [<channel-name>]"
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
NUMBER_OF_ORDERERS="$4"
NUMBER_OF_PEERS="$5"


. create-ca-compose.sh

export PATH=${PWD}/bin:$PATH

 createorg $ORG_NAME $DOMAIN_NAME $NUMBER_OF_PEERS
 if [ $NUMBER_OF_ORDERERS != 0 ]
 then 	 
 createOrderer $DOMAIN_NAME $NUMBER_OF_ORDERERS
 fi
 

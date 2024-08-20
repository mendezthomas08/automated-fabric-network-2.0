#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\org1/$1/" \
        -e "s/\example/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ./ccp-template.json
}



ORG_NAME="$1"
DOMAIN_NAME="$2"
CHANNEL_NAME="$3"
NUMBER_OF_PEERS="$4"
P0PORT=7051
CAPORT=8054

PEERPEM=../../crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/tlsca/tlsca.$ORG_NAME.$DOMAIN_NAME.com-cert.pem
CAPEM=../../crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/ca/ca.$ORG_NAME.$DOMAIN_NAME.com-cert.pem

echo "$(json_ccp $ORG_NAME $DOMAIN_NAME $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./network-config.json
#echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > ../crypto-config/peerOrganizations/$ORG_NAME.$DOMAIN_NAME.com/connection-$ORG_NAME.yaml

cat << EOF > config.json
 {
    "host": "localhost",
    "port": "4000",
    "jwt_expiretime": "36000",
    "channelName": `$CHANNEL_NAME`,
    "CC_SRC_PATH": "../..",
    "eventWaitTime": "30000",
    "admins": [
        {
            "username": "admin",
            "secret": "adminpw"
        }
    ]
}
EOF

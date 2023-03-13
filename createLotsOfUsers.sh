#!/usr/bin/bash

USERNAME=dremio
PASSWORD=dremio123
DREMIO_BASE_PATH=http://localhost:9047

NEWUSERNAME="user"
NUMUSER=5
DOMAIN="dremio.com"

read -p "Username to login with [$USERNAME]? " name
USERNAME=${name:-$USERNAME}

read -sp "Password or Personal Access Token (hit return to use the default)? "  password
PASSWORD=${password:-$PASSWORD}
echo

read -p "Dremio base path [$DREMIO_BASE_PATH]? " base_path
DREMIO_BASE_PATH=${base_path:-$DREMIO_BASE_PATH}

read -p " Base User Name: [$NEWUSERNAME]: " newusername
NEWUSERNAME=${newusername:-$NEWUSERNAME}

read -p "Domain: [$DOMAIN]: " domain
DOMAIN=${domain:-$DOMAIN}

read -p " Number of users: [$NUMUSER]: " numuser
NUMUSER=${numuser:-$NUMUSER}

DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")
echo
echo $DREMIO_AUTH_TOKEN

#{"name":"user1","email":"user1@dremio.com","firstName":"user1","lastName":"user1","password":"dremio123"}
for (( c=1; c<=$NUMUSER; c++ ))
do
 THISUSER=${NEWUSERNAME}${c}
 USER_ID=$(curl -X POST -s -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/user \
            -d'{"name":"'${THISUSER}'","email":"'${THISUSER}@${DOMAIN}'","firstName":"'${THISUSER}'","lastName":"'${THISUSER}'","password":"dremio123"}'| jq -r ".id")
 echo "USER_ID:  " ${THISUSER} " : " ${USER_ID}
done

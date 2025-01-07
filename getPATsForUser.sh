#!/bin/bash

# The username to get the PAT for
TARGETUSER=bob
USERNAME=dremio
PASSWORD=dremio123
DREMIO_BASE_PATH=http://localhost:9047

read -p "Username [$USERNAME]: " name
USERNAME=${name:-$USERNAME}

echo -n "Password or Personal Access Token (hit return to use the default):"
read -s password
echo
PASSWORD=${password:-$PASSWORD}

read -p "Dremio base path [$DREMIO_BASE_PATH]: " base_path
DREMIO_BASE_PATH=${base_path:-$DREMIO_BASE_PATH}

read -p "Target User to get PAT for [$TARGETUSER]: " targetuser
TRAGETUSER=${targetuser:-$TARGETUSER}


DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")
echo "AUTH TOKEN: $DREMIO_AUTH_TOKEN"

TARGETID=$(curl -X GET -k -s -H  'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/user/by-name/$TARGETUSER?pretty | jq -r ".id")
echo "TARGETID $TARGETID"

TOKENS=$(curl -X GET  -s -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/user/$TARGETID/token?pretty)
echo $TOKENS | jq .

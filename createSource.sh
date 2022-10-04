#!/usr/bin/bash

USERNAME=dremio
PASSWORD=dremio123
DREMIO_BASE_PATH=http://xps-15:9047

read -p "Username [$USERNAME]? " name
USERNAME=${name:-$USERNAME}

read -sp "Password or Personal Access Token (hit return to use the default)? "  password
PASSWORD=${password:-$PASSWORD}
echo

read -p "Dremio base path [$DREMIO_BASE_PATH]? " base_path
DREMIO_BASE_PATH=${base_path:-$DREMIO_BASE_PATH}

DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")
echo

SOURCE_DEFINITION=./data/CreateSource-MySQL.json
echo  "Source definition file"
read -p "[$SOURCE_DEFINITION]: " source_definition
SOURCE_DEFINITION=${source_definition:-$SOURCE_DEFINITION}


DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")

curl -X POST   -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/source -d@$SOURCE_DEFINITION -v




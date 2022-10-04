#!/usr/bin/bash

USERNAME=dremio
PASSWORD=dremio123
DREMIO_BASE_PATH=http://xps-15:9047

read -p "Username [$USERNAME]? " name
USERNAME=${name:-$USERNAME}

read -sp "Password or Personal Access Token (hit return to use the default)? " password
PASSWORD=${password:-$PASSWORD}
echo

read -p "Dremio base path [$DREMIO_BASE_PATH]? " base_path
DREMIO_BASE_PATH=${base_path:-$DREMIO_BASE_PATH}

DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")
echo

echo "All sources:"
curl -X GET -s -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN" $DREMIO_BASE_PATH/api/v3/source?pretty | jq -r '.data[].name '





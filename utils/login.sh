#!/usr/bin/bash
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


DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")

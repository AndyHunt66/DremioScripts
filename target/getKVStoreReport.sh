#!/usr/bin/bash

USERNAME=dremio
PASSWORD=dremio123
DREMIO_BASE_PATH=http://localhost:9047

read -p "Username [$USERNAME]? " name
USERNAME=${name:-$USERNAME}

read -sp "Password or Personal Access Token (hit return to use the default)? "  password
PASSWORD=${password:-$PASSWORD}
echo

read -p "Dremio base path [$DREMIO_BASE_PATH]? " base_path
DREMIO_BASE_PATH=${base_path:-$DREMIO_BASE_PATH}

DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")
echo

OUTPUT_FILE=kvStoreOut.zip
read -p "Output File name [$OUTPUT_FILE] ? " output_file
OUTPUT_FILE=${output_file:-$OUTPUT_FILE}

RESPONSE=$(curl -X GET -s -w "%{http_code}"  -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/apiv2/kvstore/report?store=none --output $OUTPUT_FILE )
RESPONSECODE=${RESPONSE: -3}

echo "HTTP Response code: $RESPONSECODE "

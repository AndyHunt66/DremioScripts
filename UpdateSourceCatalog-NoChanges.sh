#!/usr/bin/bash
USERNAME=dremio
PASSWORD=dremio123
DREMIO_BASE_PATH=http://localhost:9047
SOURCE_NAME=Samples

read -p "Username [$USERNAME]: " name
USERNAME=${name:-$USERNAME}

echo -n "Password or Personal Access Token (hit return to use the default):"
read -s password
echo
PASSWORD=${password:-$PASSWORD}

read -p "Dremio base path [$DREMIO_BASE_PATH]: " base_path
DREMIO_BASE_PATH=${base_path:-$DREMIO_BASE_PATH}

echo  "Source name"
read -p "[$SOURCE_NAME]: " source_name
SOURCE_NAME=${source_name:-$SOURCE_NAME}


DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")

# Get the basic data about the source, using the /api/v3/catalog/by-path call
RESPONSE=$(curl -X GET -s  -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/catalog/by-path/$SOURCE_NAME  )

# Extract the ID of the source
ID=$(echo ${RESPONSE} | jq -r ".id")
echo ${ID}

## Remove specific sections from the returned json, and write it out to a file
NEW_JSON=$(echo ${RESPONSE}  | jq "del(.children)" | jq "del(.contents)"  | jq "del(.links)" | jq "del(.owner)" )
#NEW_JSON=$(curl -X GET   -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/catalog/$ID   -s | jq "del(.children)" | jq "del(.contents)"  | jq "del(.links)" | jq "del(.owner)" )
echo $NEW_JSON > .tmpJson.json

# PUT the json back to Dremio
curl -X PUT   -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/catalog/$ID?pretty -d@.tmpJson.json

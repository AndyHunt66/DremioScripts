#!/usr/bin/bash

USERNAME=dremio
PASSWORD=dremio123
DREMIO_BASE_PATH=http://localhost:9047

###############
# This script reads the source json from Dremio,
# uses JQ to change one of the parameters,
# then POSTS the updated source json to Dremio to change the source.
#
#  The change is set in the line that ends with
#     jq '.config.isCachingEnabled = false')

read -p "Username [$USERNAME]? " name
USERNAME=${name:-$USERNAME}

read -sp "Password or Personal Access Token (hit return to use the default)? "  password
PASSWORD=${password:-$PASSWORD}
echo

read -p "Dremio base path [$DREMIO_BASE_PATH]? " base_path
DREMIO_BASE_PATH=${base_path:-$DREMIO_BASE_PATH}

DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")
echo


SOURCE_NAME=my_source
echo  "Name of source to retrieve details for?"
read -p "[$SOURCE_NAME]: " source_name
SOURCE_NAME=${source_name:-$SOURCE_NAME}



RESPONSE=$(curl -X GET  -s -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/catalog/by-path/$SOURCE_NAME?pretty | jq 'del(.children)' | jq '.config.isCachingEnabled = false')
echo $RESPONSE | jq .

SOURCEID=$(echo $RESPONSE | jq -r ".id"  )

RESPONSE=$(curl -X PUT -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/catalog/$SOURCEID?pretty -d"$RESPONSE")

echo $RESPONSE | jq .
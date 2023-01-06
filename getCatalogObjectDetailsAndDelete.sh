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


OBJECT_PATH=mysource/myObject
echo "Path of object to retrieve details for?"
read -p "[$OBJECT_PATH]: " objectPath
OBJECT_PATH=${objectPath:-$OBJECT_PATH}

RESPONSE=$(curl -X GET -s -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN" $DREMIO_BASE_PATH/api/v3/catalog/by-path/$OBJECT_PATH?pretty | jq 'del(.children)')
echo $RESPONSE | jq .

OBJECTID=$(echo $RESPONSE | jq -r ".id" )

DELETE="no"
read -p "Delete this object: $OBJECTID ? (yes/no) [$DELETE]: " DELETE
if [[ $DELETE == "yes" ]] ; then
  DELETERESPONSE=$(curl -X DELETE -s -w "%{http_code}" -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN" $DREMIO_BASE_PATH/api/v3/catalog/$OBJECTID)
  RESPONSECODE=${DELETERESPONSE: -3}
  echo "Delete Response Code = $RESPONSECODE"
fi

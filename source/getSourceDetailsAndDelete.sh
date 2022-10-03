#!/usr/bin/bash

source getAllSources-Terse.sh

SOURCE_NAME=my_source_name
echo  "Name of source to retrieve details for?"
read -p "[$SOURCE_NAME]: " source_name
SOURCE_NAME=${source_name:-$SOURCE_NAME}



RESPONSE=$(curl -X GET  -s -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/catalog/by-path/$SOURCE_NAME?pretty | jq 'del(.children)')
echo $RESPONSE | jq .

SOURCEID=$(echo $RESPONSE | jq -r ".id"  )


DELETE="no"
read -p "Delete this source: $SOURCEID ? (yes/no) [$DELETE]: " DELETE
if [[ $DELETE == "yes" ]] ; then
  DELETERESPONSE=$(curl -X DELETE -s -w "%{http_code}" -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/source/$SOURCEID)
  RESPONSECODE=${DELETERESPONSE: -3}
  echo "Delete Response Code = $RESPONSECODE"
fi
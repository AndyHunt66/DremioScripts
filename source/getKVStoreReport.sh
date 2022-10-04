#!/usr/bin/bash

source utils/login.sh

OUTPUT_FILE=kvStoreOut.zip
read -p "Output File name [$OUTPUT_FILE] ? " output_file
OUTPUT_FILE=${output_file:-$OUTPUT_FILE}

RESPONSE=$(curl -X GET -s -w "%{http_code}"  -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/apiv2/kvstore/report?store=none --output $OUTPUT_FILE )
RESPONSECODE=${RESPONSE: -3}

echo "HTTP Response code: $RESPONSECODE "

#!/usr/bin/bash

source utils/login.sh

echo "All sources:"
curl -X GET  -s -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/source?pretty | jq -r '.data[].name '





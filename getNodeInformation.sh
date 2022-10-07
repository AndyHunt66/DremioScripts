#!/usr/bin/bash

echo "=== WARNING====="
echo "This script uses the apiv2/system/nodes API which is undocumented and unsupported and may be removed or changed in later versions of Dremio "
echo "================"

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


curl -X GET -s -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN" $DREMIO_BASE_PATH/apiv2/system/nodes?pretty

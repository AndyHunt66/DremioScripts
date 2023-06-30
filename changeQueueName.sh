#!/usr/bin/bash

USERNAME=dremio
PASSWORD=dremio123
DREMIO_BASE_PATH=http://xps-15:9047

QUEUE='High Cost User Queries'
NEW_NAME='New Queue Name'

read -p "Username [$USERNAME]: " name
USERNAME=${name:-$USERNAME}

echo -n "Password or Personal Access Token (hit return to use the default):"
read -s password
echo
PASSWORD=${password:-$PASSWORD}

read -p "Dremio base path [$DREMIO_BASE_PATH]: " base_path
DREMIO_BASE_PATH=${base_path:-$DREMIO_BASE_PATH}

read -p "Queue to change [$QUEUE]: " queue
QUEUE=${queue:-$QUEUE}

read -p "New name [$NEW_NAME]: " new_name
NEW_NAME=${new_name:-$NEW_NAME}

QUEUE=$(echo "$QUEUE" | sed 's/ /%20/g')

DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")

#rawResponse=$(curl -s -X GET   -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/wlm/queue?pretty)
#echo $rawResponse | jq .

rawResponse=$(curl -s -X GET   -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/wlm/queue/by-name/$QUEUE)
echo $rawResponse | jq .
TAG=$(echo $rawResponse | jq -r .tag)
ID=$(echo $rawResponse | jq -r .id )
echo $TAG

rawResponse=$(curl -s -X PUT   -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/wlm/queue/$ID  -d"{\"tag\":\"$TAG\",\"name\":\"$NEW_NAME\"}" )

echo $rawResponse | jq .
#{
#  "tag": "BNGRmgfEnDg=",
#  "name": "High Cost Reflections",
#  "maxMemoryPerNodeBytes": 8589934592,
#  "maxQueryMemoryPerNodeBytes": 8589934592,
#  "cpuTier": "LOW",
#  "maxAllowedRunningJobs": 100,
#  "maxStartTimeoutMs": 300000,
#  "maxRunTimeoutMs": 300000,
#  "engineId": "DATA"
#}
#!/usr/bin/bash
clear
USERNAME=dremio
PASSWORD=dremio123
DREMIO_BASE_PATH=http://localhost:9047

read -p "Username to login with [$USERNAME]? " name
USERNAME=${name:-$USERNAME}

read -sp "Password or Personal Access Token (hit return to use the default)? "  password
PASSWORD=${password:-$PASSWORD}
echo

read -p "Dremio base path [$DREMIO_BASE_PATH]? " base_path
DREMIO_BASE_PATH=${base_path:-$DREMIO_BASE_PATH}

DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")
echo

TARGET=bob
echo  "User to get info for : "
read -p "[$TARGET]: " target
TARGET=${target:-$TARGET}


DREMIO_AUTH_TOKEN=_dremio$(curl $DREMIO_BASE_PATH/apiv2/login -k -H 'Content-Type: application/json' -d"{\"userName\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -s | jq -r ".token")
TARGET_ID=$(curl  -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/user/by-name/$TARGET -s | jq -r ".id")

echo "TARGET_ID: " $TARGET_ID

echo "User details:"
curl  -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/user/$TARGET_ID?pretty

echo
echo "User privileges:"
curl  -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/user/$TARGET_ID/privilege?pretty

echo
echo "User Home details:"
curl  -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/apiv2/home/%40$TARGET?pretty

echo
if [ $TARGET == $USERNAME ]
then
  echo "User Token:"
  curl  -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/user/$TARGET_ID/token
  echo

  GENERATE="n"
  read -p "Generate Access token? [$GENERATE] " generate
  GENERATE=${generate:-$GENERATE}
  if [ $GENERATE == "y" ]
  then
    TOKENNAME="token1"
    read -p "Token name? [$TOKENNAME] " tokenname
    TOKENNAME=${tokenname:-$TOKENNAME}
    curl -XPOST -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $DREMIO_BASE_PATH/api/v3/user/$TARGET_ID/token -d'{"label":"'$TOKENNAME'","millisecondsToExpire":1123200000}'
  fi
fi

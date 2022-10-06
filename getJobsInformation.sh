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


echo "Filter: Start time FROM  ?"
read -p "(Value in epoch miliseconds): " filterStart

echo "Filter: Start time TO  ?"
read -p "(Value in epoch miliseconds): " filterEnd

echo "Filter: Job Status ?"
read -p "(COMPLETED QUEUED SETUP ENGINE_START RUNNING CANCELED FAILED): " filterStatus

echo "Filter: Query Type ?"
read -p "(UI EXTERNAL ACCELERATION INTERNAL DOWNLOAD): " filterType

echo "Filter: User ?"
read -p "e.g. <username1> <username2> : " filterUser

echo "Filter: Queue ?"
echo "Comma delimited list of queue names"
read -p "e.g. Low Cost Reflections,High Cost User Queries  : " filterQueue

SORTCOLUMN="st"
echo "Sorting on ?"
echo " Start Time [st] "
echo " Job Status [jst]"
echo " Username [usr]"
echo " Query Type [qt]"
echo " Queue Name [qn]"
read -p "Default is [$SORTCOLUMN] : " sortColumn
SORT="sort="${sortColumn:-$SORTCOLUMN}

SORTORDER="DESCENDING"
read -p "Order [$SORTORDER] : " sortOrder
SORORDER="sort="${sortOrder:-$SORTORDER}

#http://localhost:9047/apiv2/jobs-listing/v1.0?
# detailLevel=1
# &sort=st
# &order=DESCENDING
# &filter=
# (jst%3D%3D%22COMPLETED%22%2Cjst%3D%3D%22QUEUED%22%2Cjst%3D%3D%22SETUP%22%2Cjst%3D%3D%22ENGINE_START%22%2Cjst%3D%3D%22RUNNING%22%2Cjst%3D%3D%22CANCELED%22%2Cjst%3D%3D%22FAILED%22)
# %3B(usr%3D%3D%22bob%22%2Cusr%3D%3D%22dremio%22)
# %3B(st%3Dgt%3D1665029477368%3Bst%3Dlt%3D1665051077368)
# %3B(qt%3D%3D%22UI%22%2Cqt%3D%3D%22EXTERNAL%22%2Cqt%3D%3D%22ACCELERATION%22%2Cqt%3D%3D%22INTERNAL%22%2Cqt%3D%3D%22DOWNLOAD%22)
# %3B(qn%3D%3D%22Low+Cost+Reflections%22%2Cqn%3D%3D%22High+Cost+Reflections%22%2Cqn%3D%3D%22High+Cost+User+Queries%22%2Cqn%3D%3D%22Low+Cost+User+Queries%22%2Cqn%3D%3D%22UI+Previews%22)

## WARNING
# 1   The filter has a non-consistent format
#   Note the %2C in each filter which is a URL-encoded comma.
#   Some REST api apps (Postman, Insomnia) will un-encode this before sending, which breaks the request
#
# 2  Note all the double % sings, escaping the % in the shell

FILTER=""

#  Job Status filter:    (jst%3D%3D%22COMPLETED%22)
#                 or:    (jst%3D%3D%22COMPLETED%22%2Cjst%3D%3D%22QUEUED%22)
FILTER_STATUS=""
if [[ ! -z "$filterStatus" ]]
then
  filterStatus=($filterStatus)
  FILTER_STATUS=$(printf "jst%%3D%%3D%%22%s%%22%%2C" "${filterStatus[@]}")
  FILTER_STATUS="("${FILTER_STATUS::-3}")"
  FILTER=$(printf "%s%%3B%s" ${FILTER_STATUS} ${FILTER} )
fi

#  User filter  :    (usr%3D%3D%22bob%22)
#             or:    (usr%3D%3D%22bob%22%2Cusr%3D%3D%22dremio%22)
FILTER_USER=""
if [[ ! -z "$filterUser" ]]
then
  filterUser=($filterUser)
  FILTER_USER=$(printf "usr%%3D%%3D%%22%s%%22%%2C" "${filterUser[@]}")
  FILTER_USER="("${FILTER_USER::-3}")"
  FILTER=$(printf "%s%%3B%s" ${FILTER_USER}  ${FILTER} )
fi

#  Start Of Job filter:    not encoded: (st=gt=1665029477368;st=lt=1665051077368)
#                     :        encoded: (st%3Dgt%3D1665029477368%3Bst%3Dlt%3D1665051077368)
# Either gt or lt can be omitted
FILTER_START=""
if [[ ! -z "$filterStart" || ! -z "$filterEnd" ]]
then
  if [[ ! -z "$filterStart" ]]
  then
    FILTER_START=$(printf "st%%3Dgt%%3D%s" "${filterStart}")
    if [[ ! -z "$filterEnd" ]]
    then
      FILTER_START=$(printf "%s%%3Bst%%3Dlt%%3D%s" ${FILTER_START} ${filterEnd} )
    fi
  else
    FILTER_START=$(printf "st%%3Dlt%%3D%s" ${filterEnd})
  fi
  FILTER_START="("${FILTER_START}")"
  FILTER=$(printf "%s%%3B%s"  ${FILTER_START} ${FILTER})
fi

#  Query Type filter:    (qt%3D%3D%22UI%22%2Cqt%3D%3D%22EXTERNAL%22%2Cqt%3D%3D%22ACCELERATION%22%2Cqt%3D%3D%22INTERNAL%22%2Cqt%3D%3D%22DOWNLOAD%22)
#                 or:    (qt%3D%3D%22UI%22%)
FILTER_TYPE=""
if [[ ! -z "$filterType" ]]
then
  filterType=($filterType)
  FILTER_TYPE=$(printf "qt%%3D%%3D%%22%s%%22%%2C" "${filterType[@]}")
  FILTER_TYPE="("${FILTER_TYPE::-3}")"
  FILTER=$(printf "%s%%3B%s" ${FILTER_TYPE} ${FILTER})
fi

#  Queue Name filter:    (qn%3D%3D%22Low+Cost+Reflections%22%2Cqn%3D%3D%22High+Cost+Reflections%22%2Cqn%3D%3D%22High+Cost+User+Queries%22%2Cqn%3D%3D%22Low+Cost+User+Queries%22%2Cqn%3D%3D%22UI+Previews%22)
#                 or:    (qn%3D%3D%22Low+Cost+Reflections%22%)
FILTER_QUEUE=""
if [[ ! -z "$filterQueue" ]]
then
  filterQueue=$(echo ${filterQueue} | sed  's/ /+/g' )
  IFS=',' read -r -a filterQueue <<< "$filterQueue"
  FILTER_QUEUE=$(printf "qn%%3D%%3D%%22%s%%22%%2C" "${filterQueue[@]}")
  FILTER_QUEUE="("${FILTER_QUEUE::-3}")"
  FILTER=$(printf "%s%%3B%s" ${FILTER_QUEUE} ${FILTER})
fi

FILTER=${FILTER::-3}
FILTER="filter="${FILTER}

URL=$DREMIO_BASE_PATH"/apiv2/jobs-listing/v1.0?"${SORT}"&"${ORDER}"&"${FILTER}


echo $URL

RESPONSE=$(curl -X GET -s  -k -H 'Content-Type: application/json' -H "Authorization: $DREMIO_AUTH_TOKEN"  $URL)

# WARNING - $RESPONSE must be put in double-quotes here, otherwise we get variable expansion in the shell, and in something like
#   select * from vds1
#  the * is expanded to a directory listing of the current directory
echo "$RESPONSE" | jq .


readarray -t joblist < <(echo $RESPONSE | jq  -r ' .jobs[].id ' )
readarray -t statuslist < <(echo $RESPONSE | jq  -r ' .jobs[].state ' )
readarray -t querytypelist < <(echo $RESPONSE | jq  -r ' .jobs[].queryType ' )

echo "========================"
for i in ${!joblist[@]}; do
  printf " %-3s - %-20s - %-20s - %-20s \n" $i ${joblist[$i]} ${querytypelist[$i]} ${statuslist[$i]}
done
echo "========================"



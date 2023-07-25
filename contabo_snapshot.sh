#!/bin/bash

declare -a instances

timestamp=$(date +%Y%m%d-%H%M%S)

# Load config values
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/config.conf"

# get TOKEN
ACCESS_TOKEN=$(curl -d "client_id=$CLIENT_ID" -d "client_secret=$CLIENT_SECRET" --data-urlencode "username=$API_USER" --data-urlencode "password=$API_PASSWORD" -d 'grant_type=password' 'https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token' | jq -r '.access_token')

# set trace id
TRACE_ID=$(uuidgen)

# get instances
UUID=$(uuidgen)

instances_json_responce=$(curl -X GET "https://api.contabo.com/v1/compute/instances?size=1000" -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-request-id: ${UUID}" -H "x-trace-id: ${TRACE_ID}")
echo -e "\ninstances_json_responce\n"
echo "$instances_json_responce"
echo -e "\n=============\n"

instances=($(echo ${instances_json_responce} | jq -r '.data[]|{instanceId}[]'))

# for each instance, delete the oldest snapshot and create new snapshot named with timestamp
for i in "${instances[@]}"; do


echo -e "\n ==== instanceId: $i ====\n"

  UUID=$(uuidgen)
  OLDEST_SNAPSHOT=$(curl -X GET "https://api.contabo.com/v1/compute/instances/${i}/snapshots" -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-request-id: ${UUID}" -H "x-trace-id: ${TRACE_ID}" |jq '.data'| jq -r '.[0].snapshotId')
  UUID=$(uuidgen)
  curl -X DELETE "https://api.contabo.com/v1/compute/instances/${i}/snapshots/${OLDEST_SNAPSHOT}" -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-request-id: ${UUID}" -H "x-trace-id: ${TRACE_ID}"
  UUID=$(uuidgen)
  curl -X POST "https://api.contabo.com/v1/compute/instances/${i}/snapshots" -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-request-id: ${UUID}" -H "x-trace-id: ${TRACE_ID}" -d '{"name":"'"$timestamp"'","description":"Snapshot-Description"}'
done

exit 0

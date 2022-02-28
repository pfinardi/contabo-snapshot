#!/bin/bash

declare -a instances

timestamp=$(date +%Y%m%d-%H%M%S)

# Load config values
source config.conf

# get TOKEN
ACCESS_TOKEN=$(curl -d "client_id=$CLIENT_ID" -d "client_secret=$CLIENT_SECRET" --data-urlencode "username=$API_USER" --data-urlencode "password=$API_PASSWORD" -d 'grant_type=password' 'https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token' | jq -r '.access_token')

# get instances
UUID=$(uuidgen)
instances=($(curl -X GET 'https://api.contabo.com/v1/compute/instances' -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-request-id: ${UUID}" -H 'x-trace-id: 123213' | jq -r '.data' | jq -r '.[].instanceId'))


# for each instance, delete the oldest snapshot and create new snapshot named with timestamp
for i in "${instances[@]}"; do
  UUID=$(uuidgen)
  OLDEST_SNAPSHOT=$(curl -X GET 'https://api.contabo.com/v1/compute/instances/'$i'/snapshots' -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-request-id: ${UUID}" -H 'x-trace-id: 123213' |jq '.data'| jq -r '.[0].snapshotId')
  UUID=$(uuidgen)
  curl -X DELETE 'https://api.contabo.com/v1/compute/instances/'$i'/snapshots/'$OLDEST_SNAPSHOT -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-request-id: ${UUID}" -H 'x-trace-id: 123213'
  UUID=$(uuidgen)
  curl -X POST 'https://api.contabo.com/v1/compute/instances/'$i'/snapshots' -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-request-id: ${UUID}" -H 'x-trace-id: 123213' -d '{"name":"'"$timestamp"'","description":"Snapshot-Description"}'
done

exit 0

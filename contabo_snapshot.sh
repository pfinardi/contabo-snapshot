#!/bin/bash

declare -a instances

timestamp=$(date +%Y%m%d-%H%M%S)

# Load config values
source config.conf

# get TOKEN
ACCESS_TOKEN=$(curl -d "client_id=$CLIENT_ID" -d "client_secret=$CLIENT_SECRET" --data-urlencode "username=$API_USER" --data-urlencode "password=$API_PASSWORD" -d 'grant_type=password' 'https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token' | jq -r '.access_token')

# set trace id
TRACE_ID=$(uuidgen)

# get instances
instances=($(curl -X GET 'https://api.contabo.com/v1/compute/instances' -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-request-id: 51A87ECD-754E-4104-9C54-D01AD0F83406" -H "x-trace-id: ${TRACE_ID}" | jq -r '.data' | jq -r '.[].instanceId'))


# for each instance, delete the oldest snapshot and create new snapshot named with timestamp
for i in "${instances[@]}"; do
  OLDEST_SNAPSHOT=$(curl -X GET 'https://api.contabo.com/v1/compute/instances/'$i'/snapshots' -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H 'x-request-id: 04e0f898-37b4-48bc-a794-1a57abe6aa31' -H "x-trace-id: ${TRACE_ID}" |jq '.data'| jq -r '.[0].snapshotId')
  curl -X DELETE 'https://api.contabo.com/v1/compute/instances/'$i'/snapshots/'$OLDEST_SNAPSHOT -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H 'x-request-id: 04e0f898-37b4-48bc-a794-1a57abe6aa31' -H "x-trace-id: ${TRACE_ID}"
  curl -X POST 'https://api.contabo.com/v1/compute/instances/'$i'/snapshots' -H 'Content-Type: application/json' -H "Authorization: Bearer ${ACCESS_TOKEN}" -H 'x-request-id: 04e0f898-37b4-48bc-a794-1a57abe6aa31' -H "x-trace-id: ${TRACE_ID}" -d '{"name":"'"$timestamp"'","description":"Snapshot-Description"}'
done

exit 0

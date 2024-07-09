#!/bin/bash


echo "               *                  "
echo "                                  "
echo "PREFECT_API_URL: $PREFECT_API_URL"
echo "                                  "
echo "               *                  "
# Function to read block type id
read_block_type_id() {
  request=$(curl -s "$PREFECT_API_URL/block_types/slug/docker-registry-credentials")
  block_type_id=$(echo "$response" | jq -r '.id')
  export BLOCK_TYPE_ID=$block_type_id
}
read_block_schema_id() {
  local block_type_id=$1

  local data='{
    "block_schemas": {
      "block_type_id": {
        "any_": ["'"$block_type_id"'"]
      }
    }
  }'

  response=$(curl "$PREFECT_API_URL/block_schemas/filter" \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: en-US,en;q=0.9' \
    -H 'Connection: keep-alive' \
    -H 'Content-Type: application/json' \
    -H 'DNT: 1' \
    -H 'Origin: ${PREFECT_API_URL%/*}' \
    -H 'Referer: ${PREFECT_API_URL%/*}/blocks/catalog' \
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0' \
    -H 'X-PREFECT-UI: true' \
    --data-raw "$data" \
    --insecure)

  echo "Response: $response"
  block_schema_id=$(echo "$response" | jq -r '.[0].id')
  echo "Block Schema ID: $block_schema_id before setting env variable"
  export BLOCK_SCHEMA_ID=$block_schema_id
  echo "Post ENV Block Schema ID: $BLOCK_SCHEMA_ID"
}

# Function to create docker-registry-credentials
create_docker_registry_credentials() {
  local block_type_id=$1
  local block_schema_id=$2
  local username=$DOCKER_USERNAME
  local password=$DOCKER_PASSWORD
  local registry_url="index.docker.io"
  local reauth=true

  local data='{
    "name": "seedoo-docker-registry",
    "block_schema_id": "'"$block_schema_id"'",
    "block_type_id": "'"$block_type_id"'",
    "data": {
      "username": "'"$username"'",
      "password": "'"$password"'",
      "registry_url": "'"$registry_url"'",
      "reauth": '"$reauth"'
    }
  }'
  response=$(curl "$PREFECT_API_URL/block_documents/" \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: en-US,en;q=0.9' \
    -H 'Connection: keep-alive' \
    -H 'Content-Type: application/json' \
    -H 'DNT: 1' \
    -H "Origin: $PREFECT_API_URL" \
    -H "Referer: $PREFECT_API_URL/blocks/catalog/${BLOCK_TYPE_SLUG}/create" \
    -H 'X-PREFECT-UI: true' \
    -d "$data" \
    $INSECURE)

  # Parse the response using jq
  block_docker_registry_id=$(echo "$response" | jq -r '.id')
  echo "Block Docker Registry ID: $block_docker_registry_id"
  export DOCKER_CREDS_ID="$block_docker_registry_id"
  created=$(echo "$response" | jq -r '.created')
  updated=$(echo "$response" | jq -r '.updated')
  block_type_name=$(echo "$response" | jq -r '.block_type_name // ""')
  # Add more fields as needed

  # Print the parsed output in a nice format
  echo "ID: $id"
  echo "Created: $created"
  echo "Updated: $updated"
  echo "Block Type Name: $block_type_name"
  echo "Changing the worker-dev-base-job-template.yaml file REPLACE_ME_DOCKER_CREDS_ID with $DOCKER_CREDS_ID"
  sed "s/REPLACE_ME_DOCKER_CREDS_ID/$DOCKER_CREDS_ID/g" worker-dev-base-job-template.yaml > worker-dev-base-job-template.yaml.tmp && cat worker-dev-base-job-template.yaml.tmp | grep block_document_id && cp worker-dev-base-job-template.yaml.tmp worker-dev-base-job-template.yaml && rm worker-dev-base-job-template.yaml.tmp
  echo "Replaced the docker creds id in the worker-base-job-template.yaml file"
  cat worker-dev-base-job-template.yaml | grep block_document_id
}

# Call read_block_type_id function
read_block_type_id

# Call read_block_schema_id function
read_block_schema_id $BLOCK_TYPE_ID

# Call create_docker_registry_credentials function
create_docker_registry_credentials $BLOCK_TYPE_ID $BLOCK_SCHEMA_ID
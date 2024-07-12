#!/bin/bash

prefect server start & sleep 10
export AZ_INSTANCE_HOST_IP=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)


echo "               *                         "
echo "                                         "
echo "PREFECT_API_URL: $PREFECT_API_URL        "
echo "AZ_INSTANCE_HOST_IP: $AZ_INSTANCE_HOST_IP"
echo "MKL_NUM_THREADS: $MKL_NUM_THREADS"
echo "NUMBA_NUM_THREADS: $NUMBA_NUM_THREADS"
echo "NUMBA_THREADING_LAYER: $NUMBA_THREADING_LAYER"
echo "OMP_NUM_THREADS: $OMP_NUM_THREADS"
echo "OPENBLAS_NUM_THREADS: $OPENBLAS_NUM_THREADS"
echo "SEEDOO_DB_IP: $SEEDOO_DB_IP"
echo "SEEDOO_DB_PORT: $SEEDOO_DB_PORT"
echo "SEEDOO_PRINT_SQL_DEBUG: $SEEDOO_PRINT_SQL_DEBUG"
echo "                                         "
echo "               *                         "
# Function to read block type id
read_block_type_id() {
  request=$(curl -s "$PREFECT_API_URL/block_types/slug/docker-registry-credentials")
  response=$request
  block_type_id=$(echo "$response" | jq -r '.id')
  export BLOCK_TYPE_ID=$block_type_id
  echo "Block Type ID: $BLOCK_TYPE_ID"
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

  response=$(curl -s "$PREFECT_API_URL/block_schemas/filter" \
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
    
  block_schema_id=$(echo "$response" | jq -r '.[0].id')
  export BLOCK_SCHEMA_ID=$block_schema_id
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
  response=$(curl -s "$PREFECT_API_URL/block_documents/" \
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
  echo "Created: $created"
  echo "Updated: $updated"
  echo "Block Type Name: $block_type_name"
  echo "Changing the Docker Creds in worker-dev-base-job-template.yaml file"
  sed "s/REPLACE_ME_DOCKER_CREDS_ID/$DOCKER_CREDS_ID/g" worker-dev-base-job-template.yaml > worker-dev-base-job-template.yaml.tmp && cat worker-dev-base-job-template.yaml.tmp | grep block_document_id && cp worker-dev-base-job-template.yaml.tmp worker-dev-base-job-template.yaml && rm worker-dev-base-job-template.yaml.tmp
  echo "Changing the HOST IP in worker-dev-base-job-template.yaml file"
  sed "s/REPLACE_AZ_INSTANCE_HOST_IP/$AZ_INSTANCE_HOST_IP/g" worker-dev-base-job-template.yaml > worker-dev-base-job-template.yaml.tmp && cat worker-dev-base-job-template.yaml.tmp | grep PREFECT_API_URL && cp worker-dev-base-job-template.yaml.tmp worker-dev-base-job-template.yaml && rm worker-dev-base-job-template.yaml.tmp
  
  echo "Changing the MKL_NUM_THREADS in worker-dev-base-job-template.yaml file"
  sed "s/REPLACE_MKL_NUM_THREADS/$MKL_NUM_THREADS/g" worker-dev-base-job-template.yaml > worker-dev-base-job-template.yaml.tmp && cat worker-dev-base-job-template.yaml.tmp | grep MKL_NUM_THREADS && cp worker-dev-base-job-template.yaml.tmp worker-dev-base-job-template.yaml && rm worker-dev-base-job-template.yaml.tmp
  
  echo "Changing the NUMBA_NUM_THREADS in worker-dev-base-job-template.yaml file"
  sed "s/REPLACE_NUMBA_NUM_THREADS/$NUMBA_NUM_THREADS/g" worker-dev-base-job-template.yaml > worker-dev-base-job-template.yaml.tmp && cat worker-dev-base-job-template.yaml.tmp | grep NUMBA_NUM_THREADS && cp worker-dev-base-job-template.yaml.tmp worker-dev-base-job-template.yaml && rm worker-dev-base-job-template.yaml.tmp
  
  echo "Changing the NUMBA_THREADING_LAYER in worker-dev-base-job-template.yaml file"
  sed "s/REPLACE_NUMBA_THREADING_LAYER/$NUMBA_THREADING_LAYER/g" worker-dev-base-job-template.yaml > worker-dev-base-job-template.yaml.tmp && cat worker-dev-base-job-template.yaml.tmp | grep NUMBA_THREADING_LAYER && cp worker-dev-base-job-template.yaml.tmp worker-dev-base-job-template.yaml && rm worker-dev-base-job-template.yaml.tmp
  
  echo "Changing the OMP_NUM_THREADS in worker-dev-base-job-template.yaml file"
  sed "s/REPLACE_OMP_NUM_THREADS/$OMP_NUM_THREADS/g" worker-dev-base-job-template.yaml > worker-dev-base-job-template.yaml.tmp && cat worker-dev-base-job-template.yaml.tmp | grep OMP_NUM_THREADS && cp worker-dev-base-job-template.yaml.tmp worker-dev-base-job-template.yaml && rm worker-dev-base-job-template.yaml.tmp
  
  echo "Changing the OPENBLAS_NUM_THREADS in worker-dev-base-job-template.yaml file"
  sed "s/REPLACE_OPENBLAS_NUM_THREADS/$OPENBLAS_NUM_THREADS/g" worker-dev-base-job-template.yaml > worker-dev-base-job-template.yaml.tmp && cat worker-dev-base-job-template.yaml.tmp | grep OPENBLAS_NUM_THREADS && cp worker-dev-base-job-template.yaml.tmp worker-dev-base-job-template.yaml && rm worker-dev-base-job-template.yaml.tmp
  
  echo "Changing the SEEDOO_DB_IP in worker-dev-base-job-template.yaml file"
  sed "s/REPLACE_SEEDOO_DB_IP/$SEEDOO_DB_IP/g" worker-dev-base-job-template.yaml > worker-dev-base-job-template.yaml.tmp && cat worker-dev-base-job-template.yaml.tmp | grep SEEDOO_DB_IP && cp worker-dev-base-job-template.yaml.tmp worker-dev-base-job-template.yaml && rm worker-dev-base-job-template.yaml.tmp
  
  echo "Changing the SEEDOO_DB_PORT in worker-dev-base-job-template.yaml file"
  sed "s/REPLACE_SEEDOO_DB_PORT/$SEEDOO_DB_PORT/g" worker-dev-base-job-template.yaml > worker-dev-base-job-template.yaml.tmp && cat worker-dev-base-job-template.yaml.tmp | grep SEEDOO_DB_PORT && cp worker-dev-base-job-template.yaml.tmp worker-dev-base-job-template.yaml && rm worker-dev-base-job-template.yaml.tmp
  
  echo "Changing the SEEDOO_PRINT_SQL_DEBUG in worker-dev-base-job-template.yaml file"
  sed "s/REPLACE_SEEDOO_PRINT_SQL_DEBUG/$SEEDOO_PRINT_SQL_DEBUG/g" worker-dev-base-job-template.yaml > worker-dev-base-job-template.yaml.tmp && cat worker-dev-base-job-template.yaml.tmp | grep SEEDOO_PRINT_SQL_DEBUG && cp worker-dev-base-job-template.yaml.tmp worker-dev-base-job-template.yaml && rm worker-dev-base-job-template.yaml.tmp
  
  echo "Replaced the variables in the worker-base-job-template.yaml file"
}

# Call read_block_type_id function
read_block_type_id

# Call read_block_schema_id function
read_block_schema_id $BLOCK_TYPE_ID

# Call create_docker_registry_credentials function
create_docker_registry_credentials $BLOCK_TYPE_ID $BLOCK_SCHEMA_ID

echo "Creating the worker pool"
echo "Worker Pool Name: $WORK_POOL_NAME"
echo "Worker Pool Type: $WORK_POOL_TYPE"

prefect work-pool create $WORK_POOL_NAME --type $WORK_POOL_TYPE && sleep 10 &&
prefect work-pool update $WORK_POOL_NAME --base-job-template $BASE_JOB_TEMPLATE_PATH &&
prefect deploy -n train_flow -p seedoo-custom-worker flow.py:pull_and_run_image & wait
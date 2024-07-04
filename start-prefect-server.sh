#!/bin/bash

REMOTE_HOST="seedoogpuv2"  # Remote instance hostname or IP address
COMPOSE_PATH="~/dijar-kickoff/prefect/marvin"

# Function to check HTTP response
check_http_response() {
  local url="$1"
  local response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [ "$response" -eq 200 ]; then
    return 0  # Success, HTTP 200 OK
  else
    return 1  # Failure, non-200 response
  fi
}
# Check if the prefect-server container is running on the remote instance
echo "Checking if Prefect server container is running on $REMOTE_HOST..."
if ssh "$REMOTE_HOST" 'docker compose ls --filter "NAME=marvin"'; then
  echo " =========================================================== "
  echo "  [OK] Prefect-server container is running on $REMOTE_HOST.  "
  echo " =========================================================== "

  # Check HTTP response from Prefect server
  if check_http_response "http://172.172.233.164:4200/"; then
    echo " ================================================ "
    echo "  [OK] Prefect server is running and responding.  "
    echo " ================================================ "
  else
    echo " ================================================================== "
    echo "  Prefect server container is running but not responding properly.  "
    echo " ================================================================== "
    # Remote shell into the container on the remote instance and start the prefect server
    ssh "$REMOTE_HOST" "echo $COMPOSE_PATH"
    ssh "$REMOTE_HOST" "cd $COMPOSE_PATH && docker compose down && docker compose up -d"
    exit 1
  fi
else
  echo "Prefect-server container is not running on $REMOTE_HOST."
fi

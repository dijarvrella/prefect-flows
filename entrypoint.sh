#!/usr/bin/env bash

if [ "$PREFECT_NODE_TYPE" == "server" ]; then
    echo "Starting Prefect server..."
    source /opt/prefect/entrypoint.sh
elif [ "$PREFECT_NODE_TYPE" == "worker" ]; then
    echo "Starting Prefect worker..."
    source /opt/prefect/entrypoint.sh
    prefect worker start --pool seedoo-custom-worker
else
    echo "Unknown or unspecified PREFECT_NODE_TYPE: $PREFECT_NODE_TYPE"
    exec "$@"
fi
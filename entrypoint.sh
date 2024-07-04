#!/usr/bin/env bash

if [ "$PREFECT_NODE_TYPE" == "shell" ]; then
    echo "Starting shell..."
    exec "$@"
elif [ "$PREFECT_NODE_TYPE" == "server" ]; then
    echo "Starting Prefect server..."
    # Run the server command here
elif [ "$PREFECT_NODE_TYPE" == "worker" ]; then
    echo "Starting Prefect worker..."
    # Run the worker command here
else
    echo "Unknown or unspecified PREFECT_NODE_TYPE: $PREFECT_NODE_TYPE"
    exec "$@"
fi

#!/bin/bash

# Path to your custom base job template
BASE_JOB_TEMPLATE_PATH="worker-base-job-template.yaml"

# Work pool name
WORK_POOL_NAME="seedoo-custom-worker-1"

# Work pool type (e.g., kubernetes)
WORK_POOL_TYPE="docker"

# Create the work pool with the custom base job template
prefect work-pool create "$WORK_POOL_NAME" --type "$WORK_POOL_TYPE" --base-job-template "$BASE_JOB_TEMPLATE_PATH"
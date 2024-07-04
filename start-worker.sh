#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the environment name
ENV_NAME="seedoo"

# Function to check if conda is installed
check_conda_installed() {
  if ! command -v conda &> /dev/null; then
    echo "Conda could not be found. Please install Anaconda or Miniconda first."
    exit 1
  fi
}

# Check if conda is installed
check_conda_installed

# Create the new conda environment with specific versions of libraries to avoid conflicts
echo "Creating new conda environment: $ENV_NAME"
conda create -y --name $ENV_NAME cryptography pyopenssl

# Initialize conda in the current shell session
echo "Initializing conda"
eval "$(conda shell.bash hook)"

# Activate the new environment
echo "Activating environment: $ENV_NAME"
conda activate $ENV_NAME

# Install Prefect
echo "Installing Prefect"
pip install prefect

# Start the Prefect worker with the specified pool
echo "Starting Prefect worker with pool 'seedoo-custom-worker'"
export PREFECT_API_URL="http://10.3.0.4:4200/api"
yes y | prefect worker start --pool "seedoo-custom-worker"
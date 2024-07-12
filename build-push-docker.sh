#!/bin/bash

docker build -t seedoo-prefect-base --no-cache -f Dockerfile .

docker tag seedoo-prefect-base:latest seedooinsights/prefect-worker:$1
docker tag seedoo-prefect-base:latest seedooinsights/prefect-worker:latest
docker tag seedoo-prefect-base:latest seedooinsights/prefect-base:$2
docker tag seedoo-prefect-base:latest seedooinsights/prefect-base:latest

docker push seedooinsights/prefect-worker:$1
docker push seedooinsights/prefect-worker:latest
docker push seedooinsights/prefect-base:$2
docker push seedooinsights/prefect-base:latest

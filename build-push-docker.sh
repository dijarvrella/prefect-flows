#!/bin/bash

docker build -t seedoo-prefect-base --no-cache -f Dockerfile .

docker tag seedoo-prefect-base:latest seedooinsights/prefect-agent:$1
docker tag seedoo-prefect-base:latest seedooinsights/prefect-agent:latest
docker tag seedoo-prefect-base:latest seedooinsights/prefect-base:$2
docker tag seedoo-prefect-base:latest seedooinsights/prefect-base:latest

docker push seedooinsights/prefect-agent:$1
docker push seedooinsights/prefect-agent:latest
docker push seedooinsights/prefect-base:$2
docker push seedooinsights/prefect-base:latest

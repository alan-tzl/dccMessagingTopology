#!/bin/bash

set -e

source $(pwd)/scripts/envVariables

# redis dcc
docker run -d \
  -p 4999:6379 \
  --name $DCC_TOPOLOGY_REDIS_NAME \
  --net=$DCC_TOPOLOGY_NETWORK_NAME \
  --ip=$DCC_TOPOLOGY_REDIS_IP \
  --log-opt mode=non-blocking \
  --log-opt max-buffer-size=4m \
  --log-opt max-size=100m \
  --log-opt max-file=5 \
  redis redis-server \
  --appendonly yes

# flask topology
docker run -d \
  -p 5000:8080 \
  --name $DCC_NAME_FLASK_SERVER \
  --net=$DCC_TOPOLOGY_NETWORK_NAME \
  --ip=$DCC_FLASK_SERVER_IP \
  --log-opt mode=non-blocking \
  --log-opt max-buffer-size=4m \
  --log-opt max-size=100m \
  --log-opt max-file=5 \
  $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_FLASK_SERVER:$DCC_IMG_VERSION_FLASK_SERVER \
  sh -c 'python app.py'

celery_commands=(
  "celery worker -A app.celery --loglevel=info &>/dev/null & "
  "python app.py"
)
docker run -d \
  -p 5001:8080 \
  --name $DCC_NAME_CELERY_BROKER \
  --net=$DCC_TOPOLOGY_NETWORK_NAME \
  --ip=$DCC_CELERY_BROKER_IP \
  --log-opt mode=non-blocking \
  --log-opt max-buffer-size=4m \
  --log-opt max-size=100m \
  --log-opt max-file=5 \
  $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_CELERY_BROKER:$DCC_IMG_VERSION_CELERY_BROKER \
  sh -c "${celery_commands[*]}"

docker run -d \
  -p 5002:8080 \
  --name $DCC_NAME_DATA_HANDLER \
  --net=$DCC_TOPOLOGY_NETWORK_NAME \
  --ip=$DCC_DATA_HANDLER_IP \
  --log-opt mode=non-blocking \
  --log-opt max-buffer-size=4m \
  --log-opt max-size=100m \
  --log-opt max-file=5 \
  $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_DATA_HANDLER:$DCC_IMG_VERSION_DATA_HANDLER \
  sh -c 'python app.py'
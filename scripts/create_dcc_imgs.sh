#!/bin/bash
#
# Author:
#   Alan Tai
# Program:
#   Build the base of the docker image of Flask App
# Date:
#   3/4/2018

set -e

source $(pwd)/scripts/envVariables

bold=$(tput bold)
normal=$(tput sgr0)

# login registry
docker login \
  -u $DCC_USER_NAME \
  -p $DCC_PWD \
  $DCC_ACCOUNT

set +e
$(docker inspect $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_FLASK_SERVER:$DCC_IMG_VERSION_FLASK_SERVER)
EXITCODE_OF_FLASK_SERVER_IMG_INSPECTION=$?
$(docker inspect $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_CELERY_BROKER:$DCC_IMG_VERSION_CELERY_BROKER)
EXITCODE_OF_CELERY_BROKER_IMG_INSPECTION=$?
$(docker inspect $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_DATA_HANDLER:$DCC_IMG_VERSION_DATA_HANDLER)
EXITCODE_OF_DATA_HANDLER_IMG_INSPECTION=$?
set -e

if [[ $EXITCODE_OF_FLASK_SERVER_IMG_INSPECTION -eq 1 ]]; then
  echo "DCC image, ${bold} $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_FLASK_SERVER:$DCC_IMG_VERSION_FLASK_SERVER ${normal}, already exists!"
else
  docker build \
    -t $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_FLASK_SERVER:$DCC_IMG_VERSION_FLASK_SERVER \
    --build-arg APP_DIR=$APP_DIR \
    --build-arg USER_ID=$USER_ID \
    --build-arg DCC_FLASK_SERVER_EXPOSE_PORT=$DCC_FLASK_SERVER_EXPOSE_PORT \
    -f $(pwd)/flask_server/Dockerfile .

  # push img to the registry
  docker push $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_FLASK_SERVER:$DCC_IMG_VERSION_FLASK_SERVER
fi

if [[ $EXITCODE_OF_CELERY_BROKER_IMG_INSPECTION -eq 1 ]]; then
  echo "DCC image, ${bold} $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_CELERY_BROKER:$DCC_IMG_VERSION_CELERY_BROKER ${normal}, already exists!"
else
  docker build \
    -t $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_CELERY_BROKER:$DCC_IMG_VERSION_CELERY_BROKER \
    --build-arg APP_DIR=$APP_DIR \
    --build-arg USER_ID=$USER_ID \
    --build-arg DCC_CELERY_BROKER_EXPOSE_PORT=$DCC_CELERY_BROKER_EXPOSE_PORT \
    -f $(pwd)/celery_broker/Dockerfile .

    # push img to the registry
    docker push $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_CELERY_BROKER:$DCC_IMG_VERSION_CELERY_BROKER
fi

if [[ $EXITCODE_OF_DATA_HANDLER_IMG_INSPECTION -eq 1 ]]; then
  echo "DCC image, ${bold} $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_DATA_HANDLER:$DCC_IMG_VERSION_DATA_HANDLER ${normal}, already exists!"
else
  docker build \
    -t $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_DATA_HANDLER:$DCC_IMG_VERSION_DATA_HANDLER \
    --build-arg APP_DIR=$APP_DIR \
    --build-arg USER_ID=$USER_ID \
    --build-arg DCC_DATA_HANDLER_EXPOSE_PORT=$DCC_DATA_HANDLER_EXPOSE_PORT \
    -f $(pwd)/data_handler/Dockerfile .

    # push img to the registry
    docker push $DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_DATA_HANDLER:$DCC_IMG_VERSION_DATA_HANDLER
fi

docker logout $DCC_ACCOUNT


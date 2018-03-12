#!/bin/bash
#
# Author:
#   Alan Tai
# Program:
#   Spin up the Koa application and manage the application by pm2
# Date:
#   3/4/2017

set -e

# export variables
source $(pwd)/scripts/envVariables
CWD=$(pwd)

finish() {
  local existcode=$?
  cd $CWD
  exit $existcode
}

trap "finish" INT TERM

# login registry
docker login -u $DCC_USER_NAME -p $DCC_PWD $DCC_ACCOUNT

set +e
# create a private subnet
NETWORK_INSPECTION=$(docker network inspect "$DCC_TOPOLOGY_NETWORK_NAME")
EXITCODE_NETWORK_INSPECTION=$?
[[ $EXITCODE_NETWORK_INSPECTION -ne 0 ]] || (echo "Network, $DCC_TOPOLOGY_NETWORK_NAME, exists and will be reset" && docker network rm $DCC_TOPOLOGY_NETWORK_NAME)

docker network create \
  --driver=$DCC_TOPOLOGY_NETWORK_DRIVER \
  --gateway=$DCC_TOPOLOGY_GATEWAY \
  --subnet=$DCC_TOPOLOGY_SUBNET \
  $DCC_TOPOLOGY_NETWORK_NAME

# pull imgs
# TODO: refactor the code by using loop dcc img ary
IMAGE_ARY=("$DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_FLASK_SERVER:$DCC_IMG_VERSION_FLASK_SERVER"
  "$DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_CELERY_BROKER:$DCC_IMG_VERSION_CELERY_BROKER"
  "$DCC_ACCOUNT/$DCC_IMG_DIR/$DCC_NAME_DATA_HANDLER:$DCC_IMG_VERSION_DATA_HANDLER"
)

for ith in "${IMAGE_ARY[@]}"; do
  docker pull $ith
done
set -e

docker logout $DCC_ACCOUNT

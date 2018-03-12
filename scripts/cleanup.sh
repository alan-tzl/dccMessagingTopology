#!/bin/bash
#
# Author:
#   Alan Tai
# Program:
#   Do all tasks
#   3/4/2018

set -e

source ./scripts/envVariables

cleanup() {
    echo "Cleaning docker stuff up..."
    exit
}

trap cleanup INT TERM

# clean up dcc resources
docker rm $(docker ps -qa --no-trunc --filter "status=exited")
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
docker volume rm $(docker volume ls -qf dangling=true)

# clean up networks
# docker network ls | awk '$3 == "bridge" && $2 != "bridge" { print $1 }'
# for docker 1.13
docker network prune
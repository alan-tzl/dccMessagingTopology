#!/bin/bash
#
# Author:
#   Alan Tai
# Program:
#   Do all tasks
#   3/4/2018

set -e

source ./scripts/envVariables

./scripts/config_topology.sh
./scripts/create_dcc_imgs.sh
./scripts/spin_up_dcc_topology.sh
./scripts/cleanup.sh
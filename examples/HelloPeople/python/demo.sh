#!/bin/bash

# Paths
DOCKER_COMPOSE=../../../dockers/docker-compose.yml
TOOLSPATH=../../../tools/dClayTool.sh
MODELPATH="model"
STUBSPATH="stubs"
APPPATH="bin"

# App / User info
APP=HelloPeople
USER=${APP}PythonUser
PASS=pys3cr3tp4ssw0rd
DATASET=${APP}PythonDS
NAMESPACE=${APP}_ns
set -e

# Start dataClay
docker-compose -f $DOCKER_COMPOSE down # Just in case it failed before
docker-compose -f $DOCKER_COMPOSE up -d
printf "\nWaiting for dataClay to init "
until [ "`$TOOLSPATH GetDataClayID 2>&1 | grep ERROR`" == "" ]; do
	printf "."
done
printf "\n"

# Register account
$TOOLSPATH NewAccount $USER $PASS
# Register data contract
$TOOLSPATH NewDataContract $USER $PASS $DATASET $USER

# Register model
$TOOLSPATH NewModel $USER $PASS $NAMESPACE $MODELPATH python

# Get stubs
rm -Rf $STUBSPATH; mkdir -p $STUBSPATH
$TOOLSPATH GetStubs $USER $PASS $NAMESPACE $STUBSPATH

# Run App
printf "\n\nRunning HelloPeople...\n\n"
python -u $APPPATH/hellopeople.py BobFamily Bob 30
printf "\n\n"

# Shutdown dataClay
docker-compose -f $DOCKER_COMPOSE down

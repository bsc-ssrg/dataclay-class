#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOCKERS_PATH=$SCRIPTDIR/../dockers/
DOCKER_COMPOSE=$1 

echo " #################################### " 
echo " Starting dataClay " 
echo " #################################### "

docker-compose -f $DOCKER_COMPOSE up -d


echo ""
echo " #################################### " 
echo " DataClay is ready :) " 
echo " #################################### "

#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOCKERS_PATH=$SCRIPTDIR/../dockers/
DOCKER_COMPOSE=$1
echo " #################################### " 
echo " Stopping and cleaning " 
echo " #################################### "

docker-compose -f $DOCKER_COMPOSE down

echo ""
echo " #################################### " 
echo " DataClay stopped and cleaned " 
echo " #################################### "

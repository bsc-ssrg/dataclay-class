#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOCKERS_PATH=$SCRIPTDIR/../dockers/
DOCKER_COMPOSE=$1
echo " #################################### " 
echo " Stopping and cleaning " 
echo " #################################### "
pushd $SCRIPTDIR/dockers
docker-compose -f $DOCKER_COMPOSE down
popd 

echo ""
echo ""
echo " Cleaning stubs directories "
rm -Rf $SCRIPTDIR/../app/stubs
echo " Done! " 

echo ""
echo " #################################### " 
echo " DataClay stopped and cleaned " 
echo " #################################### "

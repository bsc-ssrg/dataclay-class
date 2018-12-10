#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOCKERS_PATH=$SCRIPTDIR/../../../../dockers/
echo " #################################### " 
echo " Stopping and cleaning " 
echo " #################################### "
pushd $DOCKERS_PATH
docker-compose down
popd

echo ""
echo ""
echo " Cleaning stubs directories "
rm -Rf $SCRIPTDIR/../../dataClay1/java/stubs
rm -Rf $SCRIPTDIR/../../dataClay2/java/stubs
rm -Rf $SCRIPTDIR/../../dataClay1/python/stubs
rm -Rf $SCRIPTDIR/../../dataClay2/python/stubs
echo " Cleaning bin directories "
rm -Rf $SCRIPTDIR/../../dataClay1/java/bin
rm -Rf $SCRIPTDIR/../../dataClay2/java/bin
echo " Done! " 

echo ""
echo " #################################### " 
echo " DataClay stopped and cleaned " 
echo " #################################### "

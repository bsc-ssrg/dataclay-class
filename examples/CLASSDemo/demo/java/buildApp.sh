#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLSBASE=$SCRIPTDIR/../../../../tools/
DATACLAYLIB="$TOOLSBASE/dataclayclient.jar:$TOOLSBASE/lib/*"
DATACLAY=$1

echo ""
echo -n "Compiling for dataClay ${DATACLAY}... "
mkdir -p $SCRIPTDIR/../../dataClay${DATACLAY}/java/bin
javac -cp $SCRIPTDIR/../../dataClay${DATACLAY}/java/stubs:$DATACLAYLIB $SCRIPTDIR/../../dataClay${DATACLAY}/java/src/demo/*.java -d $SCRIPTDIR/../../dataClay${DATACLAY}/java/bin/
echo " done"
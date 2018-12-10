#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLSBASE=$SCRIPTDIR/../../../../tools/
TOOLSPATH="$TOOLSBASE/dClayTool.sh"
NAMESPACE="CityNS"
USER="CityUser"
PASS="p4ssw0rd"
DATASET="City"
DATACLAY=$1
LANG=$2

printMsg() {
	printf "\n******\n***** $1 \n******\n "
}

export DATACLAYCLIENTCONFIG=$SCRIPTDIR/../../dataClay${DATACLAY}/${LANG}/cfgfiles/client.properties
STUBSPATH="$SCRIPTDIR/../../dataClay${DATACLAY}/${LANG}/stubs"
printMsg "Get stubs"
mkdir -p $STUBSPATH
$TOOLSPATH GetStubs $USER $PASS $NAMESPACE $STUBSPATH
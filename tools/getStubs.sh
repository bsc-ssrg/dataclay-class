#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLSPATH="$SCRIPTDIR/dClayTool.sh"
NAMESPACE="CityNS"
USER="CityUser"
PASS="p4ssw0rd"
DATASET="City"
printMsg() {
	printf "\n******\n***** $1 \n******\n "
}
export DATACLAYCLIENTCONFIG=$SCRIPTDIR/../app/cfgfiles/client.properties
export DATACLAYGLOBALCONFIG=$SCRIPTDIR/../app/cfgfiles/global.properties
STUBSPATH="$SCRIPTDIR/../app/stubs"
printMsg "Get stubs"
mkdir -p $STUBSPATH
$TOOLSPATH GetStubs $USER $PASS $NAMESPACE $STUBSPATH
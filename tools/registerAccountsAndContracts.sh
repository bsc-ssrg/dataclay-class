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
# ========================================================================================= #
export DATACLAYCLIENTCONFIG=$SCRIPTDIR/../app/cfgfiles/client.properties
printMsg "Register account"
$TOOLSPATH NewAccount $USER $PASS
printMsg "Create dataset and grant access to it"
$TOOLSPATH NewDataContract $USER $PASS $DATASET $USER
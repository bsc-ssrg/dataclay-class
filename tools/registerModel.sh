#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLSPATH="$SCRIPTDIR/dClayTool.sh"
DCLIB="$TOOLSBASE/dataclayclient.jar:$TOOLSBASE/lib/*"
NAMESPACE="CityNS"
USER="CityUser"
PASS="p4ssw0rd"
DATASET="City"
MODEL=$SCRIPTDIR/../app/model
printMsg() {
	printf "\n******\n***** $1 \n******\n "
}
# ========================================================================================= #
export DATACLAYCLIENTCONFIG=$SCRIPTDIR/../app/cfgfiles/client.properties # Use connection to dataClay 1

printMsg "Register account"
$TOOLSPATH NewAccount $USER $PASS

printMsg "Create dataset and grant access to it"
$TOOLSPATH NewDataContract $USER $PASS $DATASET $USER

printMsg "Register model"
$TOOLSPATH NewModel $USER $PASS $NAMESPACE $MODEL python

# ========================================================================================= #
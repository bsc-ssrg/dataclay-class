#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOCKERS_PATH=$SCRIPTDIR/../../../../dockers/
TOOLSBASE=$SCRIPTDIR/../../../../tools/
TOOLSPATH="$TOOLSBASE/dClayTool.sh"
DCLIB="$TOOLSBASE/dataclayclient.jar:$TOOLSBASE/lib/*"
NAMESPACE="CityNS"
USER="CityUser"
PASS="p4ssw0rd"
DATASET="City"

printMsg() {
	printf "\n******\n***** $1 \n******\n "
}
# ========================================================================================= #
export DATACLAYCLIENTCONFIG=$SCRIPTDIR/../../dataClay1/java/cfgfiles/client.properties # Use connection to dataClay 1

printMsg "Register account"
$TOOLSPATH NewAccount $USER $PASS

printMsg "Create dataset and grant access to it"
$TOOLSPATH NewDataContract $USER $PASS $DATASET $USER

printMsg "Register model"
SRCPATH="../../dataClay1/java/src/model"
TMPDIRALL=`mktemp -d`
TMPDIRRESCOL=`mktemp -d`
javac -cp $DCLIB `find $SRCPATH/ -name "*.java"` -d $TMPDIRALL
$TOOLSPATH NewModel $USER $PASS $NAMESPACE $TMPDIRALL java

# ========================================================================================= #
rm -Rf $TMPDIRALL
rm -Rf $TMPDIRRESCOL
#!/bin/bash

# This script uses ssh, make sure you have ssh keys with the remote node!
echo "WARNING:  This script uses ssh, make sure you have ssh keys with the remote node! Current and remote node must have the same directory $HOME/dataclay-class"

if [ "$#" -ne 2 ]; then
	echo "ERROR: Usage: full_demo.sh user@node RPI|PC"
    exit -1
fi

REMOTE_ARCH=$2
REMOTE_DOCKER=docker-compose.yml
if [ "$REMOTE_ARCH" = "RPI" ]; then
	REMOTE_DOCKER=docker-compose_rpi.yml
fi
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REMOTE_NODE=$1 #ex: user@node
COMMONDIR=$SCRIPTDIR/../common
bash $SCRIPTDIR/stopDataClaysAndClean.sh docker-compose.yml
bash $SCRIPTDIR/startDataClay.sh docker-compose.yml # start dataClay in current node 
ssh $REMOTE_NODE "cd dataclay-class/CLASSDemo/demo/python_remote; bash stopDataClaysAndClean.sh $REMOTE_DOCKER" # stop dataClay in remote node 
ssh $REMOTE_NODE "cd dataclay-class/CLASSDemo/demo/python_remote; bash startDataClay.sh $REMOTE_DOCKER" # start dataClay in remote node 
bash $SCRIPTDIR/registerModel.sh # register accounts, contracts and model in current node
bash $SCRIPTDIR/deploy_federation.sh $REMOTE_NODE
bash $COMMONDIR/getStubs.sh 1 python # in current node

# remote node
ssh $REMOTE_NODE "cd dataclay-class/CLASSDemo/demo/common; bash registerAccountsAndContracts.sh 1 python" # register accounts and contracts in remote node
ssh $REMOTE_NODE "cd dataclay-class/CLASSDemo/demo/common; bash getStubs.sh 1 python" # get stubs in remote node

bash $SCRIPTDIR/runApp.sh python # run application
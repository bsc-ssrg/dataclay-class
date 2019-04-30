#!/bin/bash

# This script uses ssh, make sure you have ssh keys with the remote node!
echo "WARNING:  This script uses ssh, make sure you have ssh keys with the remote node! Current and remote node must have the same directory $HOME/dataclay-class"

if [ "$#" -ne 4 ]; then
	echo "ERROR: Usage: full_demo.sh user@node localIP remoteIP RPI|PC"
    exit -1
fi

REMOTE_NODE=$1 #ex: user@node
LOCAL_IP=$2 #ex 84.88.184.228
REMOTE_IP=$3 #ex 84.88.51.177
REMOTE_ARCH=$4
REMOTE_DOCKER=docker-compose.yml
if [ "$REMOTE_ARCH" = "RPI" ]; then
	REMOTE_DOCKER=docker-compose_rpi.yml
fi
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
COMMONDIR=$SCRIPTDIR/../common

# ==================================== sanity checks ============================== #
# recover ips (in case test failed)
mv $SCRIPTDIR/dockers/env/LM.environment.orig $SCRIPTDIR/dockers/env/LM.environment 
mv $SCRIPTDIR/dockers/env/DS.environment.orig $SCRIPTDIR/dockers/env/DS.environment
ssh $REMOTE_NODE "cd ~/dataclay-class/examples/CLASSDemo/demo/embedded; mv dockers/env/LM.environment.orig dockers/env/LM.environment"
ssh $REMOTE_NODE "cd ~/dataclay-class/examples/CLASSDemo/demo/embedded; mv dockers/env/DS.environment.orig dockers/env/DS.environment"
# ================================================================== #

# ==================================== initialization of configurations ============================== #
# change IPs in environment files in current and remote node 
cp $SCRIPTDIR/dockers/env/LM.environment $SCRIPTDIR/dockers/env/LM.environment.orig
sed -i "s/logicmodule1/${LOCAL_IP}/g" $SCRIPTDIR/dockers/env/LM.environment
cp $SCRIPTDIR/dockers/env/DS.environment $SCRIPTDIR/dockers/env/DS.environment.orig
sed -i "s/ds1java1/${LOCAL_IP}/g" $SCRIPTDIR/dockers/env/DS.environment
ssh $REMOTE_NODE "cd ~/dataclay-class/examples/CLASSDemo/demo/embedded; cp dockers/env/LM.environment dockers/env/LM.environment.orig; sed -i \"s/logicmodule1/${REMOTE_IP}/g\" dockers/env/LM.environment"
ssh $REMOTE_NODE "cd ~/dataclay-class/examples/CLASSDemo/demo/embedded; cp dockers/env/DS.environment dockers/env/DS.environment.orig; sed -i \"s/ds1java1/${REMOTE_IP}/g\" dockers/env/DS.environment"
# ================================================================== #

bash $SCRIPTDIR/stopDataClaysAndClean.sh docker-compose.yml
bash $SCRIPTDIR/startDataClay.sh docker-compose.yml # start dataClay in current node 
ssh $REMOTE_NODE "cd ~/dataclay-class/examples/CLASSDemo/demo/embedded; bash stopDataClaysAndClean.sh $REMOTE_DOCKER" # stop dataClay in remote node 
ssh $REMOTE_NODE "cd ~/dataclay-class/examples/CLASSDemo/demo/embedded; bash startDataClay.sh $REMOTE_DOCKER" # start dataClay in remote node 

# get stubs
bash $COMMONDIR/getStubs.sh 1 python # in current node

# remote node
ssh $REMOTE_NODE "cd ~/dataclay-class/examples/CLASSDemo/demo/common; bash registerAccountsAndContracts.sh 1 python" # register accounts and contracts in remote node
ssh $REMOTE_NODE "cd ~/dataclay-class/examples/CLASSDemo/demo/common; bash getStubs.sh 1 python" # get stubs in remote node

bash $SCRIPTDIR/runApp.sh python $REMOTE_NODE $LOCAL_IP $REMOTE_IP # run application

# recover ips 
mv $SCRIPTDIR/dockers/env/LM.environment.orig $SCRIPTDIR/dockers/env/LM.environment 
mv $SCRIPTDIR/dockers/env/DS.environment.orig $SCRIPTDIR/dockers/env/DS.environment
ssh $REMOTE_NODE "cd ~/dataclay-class/examples/CLASSDemo/demo/embedded; mv dockers/env/LM.environment.orig dockers/env/LM.environment"
ssh $REMOTE_NODE "cd ~/dataclay-class/examples/CLASSDemo/demo/embedded; mv dockers/env/DS.environment.orig dockers/env/DS.environment"

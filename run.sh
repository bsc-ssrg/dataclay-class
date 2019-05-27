#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATACLAY_TOOLS=$SCRIPTDIR/tools

# This script uses ssh, make sure you have ssh keys with the remote node!
echo "WARNING:  This script uses ssh, make sure you have ssh keys with the remote node! Current and remote node must have the same directory $HOME/dataclay-class"
echo "Usage: run.sh user@node localIP remoteIP localDockerFile remoteDockerFile virtualEnv embeddedModel?"
echo "    				localIP: local IP address "
echo "    				remoteIP: remote IP address "
echo "    				localDockerFile: path of docker file to be used in local. Ex: dockers/docker-compose.yml "
echo "    				remoteDockerFile: path of docker file to be used in local. Ex: dockers/docker-compose-arm.yml "
echo "    				virtualEnv: Path to folder of python virtual environment to use to run application. Ex: $HOME/pyenv3.5/"
echo "                        	REMEMBER that this python virtual env. should have dataclay installed (consistent version with docker image) "
echo "    				embeddedModel?: must be true or false. Indicates if we are using embedded model in docker images (avoid registering model)."


if [ "$#" -ne 7 ]; then
	echo " ERROR: wrong number of arguments "
	exit -1
fi
# ==================================== PARAMETERS ==================================== #
REMOTE_NODE=$1 #ex: user@node
LOCAL_IP=$2 #ex 84.88.184.228
REMOTE_IP=$3 #ex 84.88.51.177
LOCAL_DOCKER_FILE=$4
REMOTE_DOCKER_FILE=$5
VIRTUAL_ENV=$6
EMBEDDED_MODEL=$7
if [ ! -f "$LOCAL_DOCKER_FILE" ]; then
	echo "ERROR: $LOCAL_DOCKER_FILE does not exist. Provide a valid docker file "
    exit -1
fi
if [ ! -f "$REMOTE_DOCKER_FILE" ]; then
	echo "ERROR: $REMOTE_DOCKER_FILE does not exist. Provide a valid docker file "
    exit -1
fi
if [ "$EMBEDDED_MODEL" != "true" ] && [ "$EMBEDDED_MODEL" != "false" ]; then
	echo "ERROR: Last parameter should be true or false. True if model is embedded in docker image. Flase otherwise. "
    exit -1
fi
# ==================================== IPS ==================================== #

# recover ips (in case test failed)
mv $SCRIPTDIR/dockers/env/LM.environment.orig $SCRIPTDIR/dockers/env/LM.environment 
mv $SCRIPTDIR/dockers/env/DS.environment.orig $SCRIPTDIR/dockers/env/DS.environment
ssh $REMOTE_NODE "cd ~/dataclay-class/; mv dockers/env/LM.environment.orig dockers/env/LM.environment"
ssh $REMOTE_NODE "cd ~/dataclay-class/; mv dockers/env/DS.environment.orig dockers/env/DS.environment"

# change IPs in environment files in current and remote node 
cp $SCRIPTDIR/dockers/env/LM.environment $SCRIPTDIR/dockers/env/LM.environment.orig
sed -i "s/logicmodule1/${LOCAL_IP}/g" $SCRIPTDIR/dockers/env/LM.environment
cp $SCRIPTDIR/dockers/env/DS.environment $SCRIPTDIR/dockers/env/DS.environment.orig
sed -i "s/ds1java1/${LOCAL_IP}/g" $SCRIPTDIR/dockers/env/DS.environment
ssh $REMOTE_NODE "cd ~/dataclay-class/; cp dockers/env/LM.environment dockers/env/LM.environment.orig; sed -i \"s/logicmodule1/${REMOTE_IP}/g\" dockers/env/LM.environment"
ssh $REMOTE_NODE "cd ~/dataclay-class/; cp dockers/env/DS.environment dockers/env/DS.environment.orig; sed -i \"s/ds1java1/${REMOTE_IP}/g\" dockers/env/DS.environment"

# ==================================== DATACLAY START ==================================== #

bash $DATACLAY_TOOLS/stopDataClaysAndClean.sh $LOCAL_DOCKER_FILE
bash $DATACLAY_TOOLS/startDataClay.sh $LOCAL_DOCKER_FILE # start dataClay in current node 
ssh $REMOTE_NODE "cd ~/dataclay-class/; bash tools/stopDataClaysAndClean.sh $REMOTE_DOCKER_FILE" # stop dataClay in remote node 
ssh $REMOTE_NODE "cd ~/dataclay-class/; bash tools/startDataClay.sh $REMOTE_DOCKER_FILE" # start dataClay in remote node 

if [ "$EMBEDDED_MODEL" != "true" ]; then
	bash $DATACLAY_TOOLS/registerModel.sh # register accounts, contracts and model in current node
	bash $DATACLAY_TOOLS/deploy_federation.sh $REMOTE_NODE
	ssh $REMOTE_NODE "cd ~/dataclay-class; bash tools/registerAccountsAndContracts.sh" # register accounts and contracts in remote node
fi

# GET STUBS
bash $DATACLAY_TOOLS/getStubs.sh # get stubs 
ssh $REMOTE_NODE "cd ~/dataclay-class; bash tools/getStubs.sh" # get stubs in remote node


# ==================================== APP ==================================== #

pushd $SCRIPTDIR/app/
bash $SCRIPTDIR/app/run_app.sh $REMOTE_NODE $LOCAL_IP $REMOTE_IP $VIRTUAL_ENV # run application
popd 

# ==================================== CLEAN ==================================== #

# recover ips 
mv $SCRIPTDIR/dockers/env/LM.environment.orig $SCRIPTDIR/dockers/env/LM.environment 
mv $SCRIPTDIR/dockers/env/DS.environment.orig $SCRIPTDIR/dockers/env/DS.environment
ssh $REMOTE_NODE "cd ~/dataclay-class/; mv dockers/env/LM.environment.orig dockers/env/LM.environment"
ssh $REMOTE_NODE "cd ~/dataclay-class/; mv dockers/env/DS.environment.orig dockers/env/DS.environment"

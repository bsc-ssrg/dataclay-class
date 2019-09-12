#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATACLAY_TOOLS=$SCRIPTDIR/tools

# This script uses ssh, make sure you have ssh keys with the remote node!
echo "WARNING:  This script uses ssh, make sure you have ssh keys with the remote node! Current and remote node must have the same directory $HOME/dataclay-class"
echo "Usage: run.sh user@node localAddr remoteAddr localDockerFile remoteDockerFile python-version dataclay-version ssl?"
echo "    				localAddr: local IP address with dataClay logicmodule exposed port. ex 84.88.184.228:11034 "
echo "    				remoteAddr: remote IP address with dataClay logicmodule exposed port.  ex 84.88.51.177:11034 "
echo "    				localDockerFile: path of docker file to be used in local. Ex: dockers/docker-compose.yml "
echo "    				remoteDockerFile: path of docker file to be used in local. Ex: dockers/docker-compose-arm.yml "
echo "    				python-version: Python version. "
echo "    				dataclay-version: DataClay version. "
echo " 						REMEMBER that python version and dataclay version should be consistent with docker images being used. "
echo "                  ssl?: can be true or false Indicates we want to use secure connections."

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
PYTHON_VERSION=$6
DATACLAY_VERSION=$7
USE_SSL=$8
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
ssh $REMOTE_NODE "cd ~/dataclay-class/; mv dockers/env/LM.environment.orig dockers/env/LM.environment"

# change IPs in environment files in current and remote node 
cp $SCRIPTDIR/dockers/env/LM.environment $SCRIPTDIR/dockers/env/LM.environment.orig
sed -i "s/logicmodule1/${LOCAL_IP}/g" $SCRIPTDIR/dockers/env/LM.environment
ssh $REMOTE_NODE "cd ~/dataclay-class/; cp dockers/env/LM.environment dockers/env/LM.environment.orig; sed -i \"s/logicmodule1/${REMOTE_IP}/g\" dockers/env/LM.environment"

# ==================================== DATACLAY START ==================================== #

bash $DATACLAY_TOOLS/stopDataClaysAndClean.sh $LOCAL_DOCKER_FILE
bash $DATACLAY_TOOLS/startDataClay.sh $LOCAL_DOCKER_FILE # start dataClay in current node 
ssh $REMOTE_NODE "cd ~/dataclay-class/; bash tools/stopDataClaysAndClean.sh $REMOTE_DOCKER_FILE" # stop dataClay in remote node 
ssh $REMOTE_NODE "cd ~/dataclay-class/; bash tools/startDataClay.sh $REMOTE_DOCKER_FILE" # start dataClay in remote node 

# GET STUBS
bash $DATACLAY_TOOLS/getStubs.sh # get stubs 
ssh $REMOTE_NODE "cd ~/dataclay-class; bash tools/getStubs.sh" # get stubs in remote node

# ==================================== APP ==================================== #


# === prepare configuration === 
rm -f $SCRIPTDIR/app/cfgfiles/client.properties
rm -f $SCRIPTDIR/app/cfgfiles/global.properties
# check if we should use SSL
if [ "$USE_SSL" == "true" ]; then
	printf "HOST=127.0.0.1\nTCPPORT=443" > $SCRIPTDIR/app/cfgfiles/client.properties
	printf "CHECK_LOG4J_DEBUG=false\nSSL_CLIENT_TRUSTED_CERTIFICATES=/traefik/cert/frontend.cert\nSSL_CLIENT_CERTIFICATE=/traefik/cert/frontend.cert\nSSL_CLIENT_KEY=/traefik/cert/frontend.key" > $SCRIPTDIR/app/cfgfiles/global.properties
	
else
	printf "HOST=127.0.0.1\nTCPPORT=11034" > $SCRIPTDIR/app/cfgfiles/client.properties
	printf "CHECK_LOG4J_DEBUG=false" > $SCRIPTDIR/app/cfgfiles/global.properties
fi
# ======= #

# run app
pushd $SCRIPTDIR/app/
bash $SCRIPTDIR/app/run_app.sh $REMOTE_NODE $LOCAL_IP $REMOTE_IP $PYTHON_VERSION $DATACLAY_VERSION # run application
popd 

# ==================================== CLEAN ==================================== #

# recover ips 
mv $SCRIPTDIR/dockers/env/LM.environment.orig $SCRIPTDIR/dockers/env/LM.environment 
ssh $REMOTE_NODE "cd ~/dataclay-class/; mv dockers/env/LM.environment.orig dockers/env/LM.environment"
rm -f $SCRIPTDIR/app/cfgfiles/client.properties
rm -f $SCRIPTDIR/app/cfgfiles/global.properties
rm -Rf $SCRIPTDIR/app/stubs
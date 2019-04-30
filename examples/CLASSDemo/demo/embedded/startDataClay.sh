#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLS_PATH=$SCRIPTDIR/../../../../tools/
DOCKERS_PATH=$SCRIPTDIR/../../../../dockers/
DOCKER_COMPOSE=$1 
NUM_NODES=1

function waitForBackends {  
	TMPDIR=`mktemp -d`
	echo " ** Waiting for backends to be ready in dataClay with LM port ${1}, language ${2} and number of sl ${3} ** "
	printf "HOST=127.0.0.1\nTCPPORT=$1" > $TMPDIR/client.properties
	export DATACLAYCLIENTCONFIG=$TMPDIR/client.properties
	DATACLAY_ADMIN_USER=admin
	DATACLAY_ADMIN_PASSWORD=admin
	LANGUAGE=$2
	NUMBER_OF_SL=$3
	NUMBER_OF_EE_PER_SL=1
	DATACLAY_TOOL=$TOOLS_PATH/dClayTool.sh
	DSCOUNTER=1
	while [ $DSCOUNTER -le $NUMBER_OF_SL ]; do
		$TOOLS_PATH/dClayTool.sh GetBackends $DATACLAY_ADMIN_USER $DATACLAY_ADMIN_PASSWORD $LANGUAGE
		NUMBER_OF_EE=`$DATACLAY_TOOL GetBackends $DATACLAY_ADMIN_USER $DATACLAY_ADMIN_PASSWORD $LANGUAGE | grep -e "^DS$DSCOUNTER" | wc -l`
		if [ ${NUMBER_OF_EE:-0} -lt $NUMBER_OF_EE_PER_SL ]; then
		  sleep 2
		else
		  echo "[`date`] *** DataService DS$DSCOUNTER for language $LANGUAGE is ready"
		  let DSCOUNTER+=1
		fi
	done
}

echo " #################################### " 
echo " Starting dataClay " 
echo " #################################### "

pushd $SCRIPTDIR/dockers
docker-compose -f $DOCKER_COMPOSE up -d logicmodule1
sleep 3
docker-compose -f $DOCKER_COMPOSE up -d ds1java1
sleep 3
docker-compose -f $DOCKER_COMPOSE up -d ds1pythonee1
sleep 3
popd 

#wait for backends to be ready
# ignore debug ports (8000 something)
#LM_PORT=`docker port dockers_logicmodule1_1 | grep -v "8[0-9][0-9][0-9]" | head -1 | sed 's/.*\://'`
LM_PORT=11034
waitForBackends $LM_PORT java $NUM_NODES
waitForBackends $LM_PORT python $NUM_NODES

echo ""
echo " #################################### " 
echo " DataClay is ready :) " 
echo " #################################### "

#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLS_PATH=$SCRIPTDIR/../../../../tools/
DOCKERS_PATH=$SCRIPTDIR/../../../../dockers/

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
echo " Starting dataClays " 
echo " #################################### "
pushd $DOCKERS_PATH
docker-compose up -d
popd

NUM_DCS=2
NUM_NODES=2
for (( CUR_DC=1; CUR_DC<=$NUM_DCS; CUR_DC++ ))
do
	#wait for backends to be ready
	# ignore debug ports (8000 something)
	LM_PORT=`docker port dockers_logicmodule${CUR_DC}_1 | grep -v "8[0-9][0-9][0-9]" | head -1 | sed 's/.*\://'`
	waitForBackends $LM_PORT java $NUM_NODES
    waitForBackends $LM_PORT python $NUM_NODES
done

echo ""
echo " #################################### " 
echo " DataClay is ready :) " 
echo " #################################### "

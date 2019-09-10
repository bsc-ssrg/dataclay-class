#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLSBASE="$SCRIPTDIR/../tools"
TOOLSPATH="$TOOLSBASE/dClayTool.sh"
DCLIB="$TOOLSBASE/dataclayclient.jar"
MODEL="$SCRIPTDIR/src/"
DATACLAY_TAG="2.0.dev10"
NAMESPACE="CityNS"
USER="CityUser"
PASS="p4ssw0rd"
DATASET="City"

function usage {
	echo " USAGE: $0 [--push]"
	echo "		--push Indicates to push to DockerHub "
	echo ""
}

function docker-push-class {

	# 
	docker push dataclayclass/dspython:py2.7
	docker push dataclayclass/dspython:py3.6
	docker push dataclayclass/logicmodule
	docker push dataclayclass/dsjava
	
	# ARM
	docker push dataclayclass/dspython:arm-py2.7 
	docker push dataclayclass/dspython:arm-py3.6
	docker push dataclayclass/logicmodule:arm
	docker push dataclayclass/dsjava:arm
	
	echo "
	  Pushed images to Docker Hub:
	
		# i386
		dataclayclass/dspython:py2.7
		dataclayclass/dspython:py3.6
		dataclayclass/logicmodule
		dataclayclass/dsjava
		
		# ARM
		dataclayclass/dspython:arm-py2.7 
		dataclayclass/dspython:arm-py3.6
		dataclayclass/logicmodule:arm
		dataclayclass/dsjava:arm
	"
	
}  

echo " Welcome! this script is intended to: "
echo "		- Build new docker images for class with already registered model, contracts, ..." 
echo "		- If push option selected: Publish dataClay version class dockers in DockerHub "

if [ "$#" -ne 0 ] && [ "$#" -ne 1 ]; then
	usage
    exit -1
fi

# Check parameters
PUSH=false
PUSH_PARAM=""

echo " ===== Cleaning ====="
rm -rf $SCRIPTDIR/deploy
rm -f $SCRIPTDIR/LM.sqlite

# Check push repositories
if [ "$#" -eq 1 ]; then
	PUSH_PARAM=$1	
	if [ "$PUSH_PARAM" != "--push" ]; then 
		usage
		exit -1
	else 
		PUSH=true
	fi
fi

# Prepare client.properties
TMPDIR=`mktemp -d`
printf "HOST=127.0.0.1\nTCPPORT=11034" > $TMPDIR/client.properties
export DATACLAYCLIENTCONFIG=$TMPDIR/client.properties

# Build and start dataClay
pushd $SCRIPTDIR/dockers
echo " ===== Starting dataClay ===== "
docker-compose -f docker-compose.yml down #sanity check
docker-compose -f docker-compose.yml up -d
popd 

echo " ===== Register $USER account ====="
$TOOLSPATH NewAccount $USER $PASS

echo " ===== Create dataset $DATASET and grant access to it ====="
$TOOLSPATH NewDataContract $USER $PASS $DATASET $USER

echo " ===== Register model in $MODEL  ====="
TMPDIR=`mktemp -d`
$TOOLSPATH NewModel $USER $PASS $NAMESPACE $MODEL python
rm -Rf $TMPDIR

echo " ===== Retrieving execution classes into $SCRIPTDIR/execClasses  ====="
# Copy execClasses from dsjava docker
rm -rf $SCRIPTDIR/deploy
mkdir -p $SCRIPTDIR/deploy
docker cp dockers_ds1pythonee1_1:/usr/src/app/deploy/ $SCRIPTDIR

echo " ===== Retrieving SQLITE LM into $SCRIPTDIR/LM.sqlite  ====="
rm -f $SCRIPTDIR/LM.sqlite
TABLES="account credential contract interface ifaceincontract opimplementations datacontract dataset accessedimpl accessedprop type java_type python_type memoryfeature cpufeature langfeature archfeature prefetchinginfo implementation python_implementation java_implementation annotation property java_property python_property operation java_operation python_operation metaclass java_metaclass python_metaclass namespace"
for table in $TABLES;
do
	docker exec -t dockers_logicmodule1_1 sqlite3 "//tmp/dataclay/LM" ".dump $table" >> $SCRIPTDIR/LM.sqlite
done

echo " ===== Stopping dataClay ====="
pushd $SCRIPTDIR/dockers
docker-compose -f docker-compose.yml down
popd

# Now we can build the docker images 
echo " ===== Building docker dataclayclass/logicmodule using tag $DATACLAY_TAG ====="
docker build --build-arg DATACLAY_TAG=$DATACLAY_TAG -f DockerfileLMCLASS -t dataclayclass/logicmodule .

echo " ===== Building docker dataclayclass/dsjava using tag $DATACLAY_TAG ====="
docker pull bscdataclay/dsjava:$DATACLAY_TAG
docker tag bscdataclay/dsjava:$DATACLAY_TAG dataclayclass/dsjava

echo " ===== Building docker dataclayclass/dspython:py2.7 using tag $DATACLAY_TAG-py2.7 ====="
docker build --build-arg DATACLAY_TAG="$DATACLAY_TAG-py2.7" -f DockerfileEECLASS -t dataclayclass/dspython:py2.7 .

echo " ===== Building docker dataclayclass/dspython:py3.6 using tag $DATACLAY_TAG-py3.6 ====="
docker build --build-arg DATACLAY_TAG="$DATACLAY_TAG-py3.6" -f DockerfileEECLASS -t dataclayclass/dspython:py3.6 .

echo " ===== Building docker dataclayclass/dspython:arm-py2.7 using tag $DATACLAY_TAG-arm-py2.7 ====="
docker build --build-arg DATACLAY_TAG="$DATACLAY_TAG-arm-py2.7" -f DockerfileEECLASS-arm -t dataclayclass/dspython:arm-py2.7 .

echo " ===== Building docker dataclayclass/dspython:arm-py3.6 using tag $DATACLAY_TAG-arm-py3.6 ====="
docker build --build-arg DATACLAY_TAG="$DATACLAY_TAG-arm-py3.6" -f DockerfileEECLASS-arm -t dataclayclass/dspython:arm-py3.6 .

echo " ===== Building docker dataclayclass/logicmodule:arm using tag $DATACLAY_TAG-arm ====="
docker build --build-arg DATACLAY_TAG=$DATACLAY_TAG-arm -f DockerfileLMCLASS-arm -t dataclayclass/logicmodule:arm .

echo " ===== Building docker dataclayclass/dsjava:arm using tag $DATACLAY_TAG-arm ====="
docker pull bscdataclay/dsjava:$DATACLAY_TAG-arm
docker tag bscdataclay/dsjava:$DATACLAY_TAG-arm dataclayclass/dsjava:arm



if [ "$PUSH" = true ] ; then
	echo " ===== Pushing dockers dataclay class dockers DockerHub ====="
	docker-push-class 
else 
	echo " ===== NOT Pushing any docker into DockerHub ====="
fi



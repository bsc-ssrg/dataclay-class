#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLSBASE="$SCRIPTDIR/../tools"
TOOLSPATH="$TOOLSBASE/dClayTool.sh"
DCLIB="$TOOLSBASE/dataclayclient.jar"
MODEL="$SCRIPTDIR/src/"
DATACLAY_TAG="2.0.dev8"
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
	docker push bscdataclay/dspython:class-py2.7
	docker push bscdataclay/dspython:class-py3.6
	docker push bscdataclay/logicmodule:class
	docker push bscdataclay/dsjava:class
	
	# ARM
	docker push bscdataclay/dspython:rpi-class-py2.7 
	docker push bscdataclay/dspython:rpi-class-py3.6
	docker push bscdataclay/logicmodule:rpi-class
	docker push bscdataclay/dsjava:rpi-class
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
rm -f psql_dump.sql
rm -rf $SCRIPTDIR/execClasses
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
printf "HOST=127.0.0.1\nTCPPORT=1034" > $TMPDIR/client.properties
export DATACLAYCLIENTCONFIG=$TMPDIR/client.properties

# Build and start dataClay
pushd $SCRIPTDIR/../dockers
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
rm -f $SCRIPTDIR/LM.dump

TABLES="account credential contract interface ifaceincontract opimplementations datacontract dataset accessedimpl accessedprop type java_type python_type memoryfeature cpufeature langfeature archfeature prefetchinginfo implementation python_implementation java_implementation annotation property java_property python_property operation java_operation python_operation metaclass java_metaclass python_metaclass namespace"
for table in $TABLES;
do
	docker exec -t dockers_logicmodule1_1 sqlite3 "//tmp/dataclay/LM" ".dump $table" >> $SCRIPTDIR/LM.dump
done
sqlite3 $SCRIPTDIR/LM.sqlite ".read $SCRIPTDIR/LM.dump"

echo " ===== Stopping dataClay ====="
pushd $SCRIPTDIR/../dockers
docker-compose -f docker-compose.yml down
popd

# Now we can build the docker images 
echo " ===== Building docker bscdataclay/logicmodule:class ====="
docker build --build-arg DATACLAY_JDK="openjdk8" -f DockerfileLMCLASS -t bscdataclay/logicmodule:class .

echo " ===== Building docker bscdataclay/dsjava:class ====="
docker tag bscdataclay/dsjava:trunk bscdataclay/dsjava:class 

echo " ===== Building docker bscdataclay/dspython:class-py2.7 ====="
docker build --build-arg DATACLAY_PYVER="py2.7" -f DockerfileEECLASS -t bscdataclay/dspython:class-py2.7 .

echo " ===== Building docker bscdataclay/dspython:class-py3.6 ====="
docker build --build-arg DATACLAY_PYVER="py3.6" -f DockerfileEECLASS -t bscdataclay/dspython:class-py3.6 .

echo " ===== Building docker bscdataclay/dspython:rpi-class-py2.7 ====="
docker build --build-arg DATACLAY_PYVER="py2.7" -f DockerfileEECLASS-rpi -t bscdataclay/dspython:rpi-class-py2.7 .

echo " ===== Building docker bscdataclay/dspython:rpi-class-py3.6 ====="
docker build --build-arg DATACLAY_PYVER="py3.6" -f DockerfileEECLASS-rpi -t bscdataclay/dspython:rpi-class-py3.6 .

echo " ===== Building docker bscdataclay/logicmodule:rpi-class ====="
docker build --build-arg DATACLAY_JDK="openjdk8" -f DockerfileLMCLASS-zulu -t bscdataclay/logicmodule:rpi-class .

echo " ===== Building docker bscdataclay/dsjava:rpi-class ====="
docker pull bscdataclay/dsjava:rpi-zulujdk
docker tag bscdataclay/dsjava:rpi-zulujdk bscdataclay/dsjava:rpi-class



if [ "$PUSH" = true ] ; then
	echo " ===== Pushing dockers dataclay class dockers DockerHub ====="
	docker-push-class 
else 
	echo " ===== NOT Pushing any docker into DockerHub ====="
fi



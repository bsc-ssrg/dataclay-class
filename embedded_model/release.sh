#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLSBASE="$SCRIPTDIR/../tools"
TOOLSPATH="$TOOLSBASE/dClayTool.sh"
DCLIB="$TOOLSBASE/dataclayclient.jar"
MODEL="$SCRIPTDIR/model/src/"
NAMESPACE="classNS"
USER="class"
PASS="p4ssw0rd"
DATASET="class"
STUBSPATH="$SCRIPTDIR/wrapper/stubs"
function usage {
	echo " USAGE: $0 [--push]"
	echo "		--push Indicates to push to DockerHub "
	echo ""
}

function docker-push-class {
	TAG=class
	docker push bscdataclay/logicmodule:${TAG}
	docker push bscdataclay/dsjava:${TAG}
	docker push bscdataclay/dspython:${TAG}

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
pushd $SCRIPTDIR/dockers
echo " ===== Starting dataClay ===== "
docker-compose down #sanity check
docker-compose up -d
popd 

echo " ===== Register $USER account ====="
$TOOLSPATH NewAccount $USER $PASS

echo " ===== Create dataset $DATASET and grant access to it ====="
$TOOLSPATH NewDataContract $USER $PASS $DATASET $USER

echo " ===== Register model in $MODEL  ====="
TMPDIR=`mktemp -d`
printMsg "Register model"
$TOOLSPATH NewModel $USER $PASS $NAMESPACE $MODEL python
rm -Rf $TMPDIR

echo " ===== Retrieving execution classes into $SCRIPTDIR/execClasses  ====="
# Copy execClasses from dsjava docker
rm -rf $SCRIPTDIR/execClasses
mkdir -p $SCRIPTDIR/execClasses
docker cp dockers_ds1pythonee1_1:/usr/src/dataclay/execClasses/ $SCRIPTDIR

echo " ===== Retrieving SQLITE LM into $SCRIPTDIR/LM.sqlite  ====="
rm -f $SCRIPTDIR/LM.sqlite
TABLES="account credential contract interface ifaceincontract opimplementations datacontract dataset accessedimpl accessedprop type java_type python_type memoryfeature cpufeature langfeature archfeature prefetchinginfo implementation python_implementation java_implementation annotation property java_property python_property operation java_operation python_operation metaclass java_metaclass python_metaclass namespace"
for table in $TABLES;
do
	docker exec -t dockers_logicmodule1_1 sqlite3 "//tmp/dataclay/LM" ".dump $table" >> $SCRIPTDIR/LM.sqlite
done

echo " ===== Stopping dataClay ====="
pushd $SCRIPTDIR/dockers
docker-compose down
popd

# Now we can build the docker images 
echo " ===== Building docker bscdataclay/logicmodule:class ====="
docker build --build-arg DATACLAY_JDK="openjdk8" -f DockerfileLMCLASS -t bscdataclay/logicmodule:class .

echo " ===== Building docker bscdataclay/dsjava:class ====="
docker tag bscdataclay/dsjava:trunk bscdataclay/dsjava:class 

echo " ===== Building docker bscdataclay/dspython:class-py2.7 ====="
docker build --build-arg DATACLAY_PYVER="2.7" -f DockerfileEECLASS -t bscdataclay/dspython:class-py2.7 .

echo " ===== Building docker bscdataclay/dspython:class-py3.6 ====="
docker build --build-arg DATACLAY_PYVER="3.6" -f DockerfileEECLASS -t bscdataclay/dspython:class-py3.6 .

if [ "$PUSH" = true ] ; then
	echo " ===== Pushing dockers dataclay class dockers DockerHub ====="
	docker-push-class 
else 
	echo " ===== NOT Pushing any docker into DockerHub ====="
fi



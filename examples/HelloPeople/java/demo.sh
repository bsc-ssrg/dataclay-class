#!/bin/bash

# Paths
DOCKER_COMPOSE="../../../dockers/docker-compose.yml"
TOOLSPATH="../../../tools/dClayTool.sh"
DCLIBPATH="../../../tools/dataclayclient.jar"
DCDEPSPATH="../../../tools/lib/"
SRCPATH="src/model"
STUBSPATH="stubs"
BINPATH="bin"

# App / User info
APP=HelloPeople
USER=${APP}User
PASS=s3cr3tp4ssw0rd
DATASET=${APP}DS
NAMESPACE=${APP}NS
set -e

# Start dataClay !
docker-compose -f $DOCKER_COMPOSE down # Just in case it failed before
docker-compose -f $DOCKER_COMPOSE up -d
printf "\nWaiting for dataClay to init "
until [ "`$TOOLSPATH GetDataClayID 2>&1 | grep ERROR`" == "" ]; do
	printf "."
done
printf "\n"

# Register account
$TOOLSPATH NewAccount $USER $PASS
# Register data contract
$TOOLSPATH NewDataContract $USER $PASS $DATASET $USER
# Compile model 
TMPBINPATH=`mktemp -d` #Store compiled model .class files in temporary dir
javac `find $SRCPATH/*.java | grep java` -d $TMPBINPATH
# Register model
$TOOLSPATH NewModel $USER $PASS $NAMESPACE $TMPBINPATH java
#rm -Rf $TMPBINPATH #Remove temporary dir of compiled model

# Get stubs
rm -Rf $STUBSPATH; mkdir -p $STUBSPATH
$TOOLSPATH GetStubs $USER $PASS $NAMESPACE $STUBSPATH

# Define classpath
export CLASSPATH=$STUBSPATH:$BINPATH:$DCLIBPATH:$DCDEPSPATH/*:$CLASSPATH

# Compile app with stubs
rm -Rf $BINPATH; mkdir $BINPATH
javac src/app/*.java -d bin/

# Exec demo
java -Dorg.apache.logging.log4j.simplelog.StatusLogger.level=OFF \
	app.HelloPeople BobFamily Bob 30

# Shutdown dataClay !
docker-compose -f $DOCKER_COMPOSE down

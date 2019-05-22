#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLSBASE=$SCRIPTDIR/../../../../tools/
TOOLSPATH="$TOOLSBASE/dClayTool.sh"
CLASSPATH="$TOOLSBASE/dataclayclient.jar:$TOOLSBASE/lib/*:lib/*"
LOG4JCONF=-Dlog4j.configurationFile=file:cfglog/log4j2.xml
#LOG4JCONF=-Dorg.apache.logging.log4j.simplelog.StatusLogger.level=OFF
LANG=$1
REMOTE_NODE=$2 #ex: user@node
LOCAL_IP=$3 #ex 84.88.184.228
REMOTE_IP=$4 #ex 84.88.51.177
VIRTUAL_ENV=$5

echo " #################################### " 
echo " # RUNNING DEMO "
echo " #################################### " 
echo ""

# Export variables for demo
export DATACLAY1_IP=$LOCAL_IP
export DATACLAY1_PORT=11034
export DATACLAY2_IP=$REMOTE_IP
export DATACLAY2_PORT=11034


if [ ! -d "${VIRTUAL_ENV}" ]; then
	echo " Missing virtual environment $VIRTUAL_ENV " 
	exit -1
fi
echo " Calling python installation in virtual environment $VIRTUAL_ENV " 
source $VIRTUAL_ENV/bin/activate
echo " Using python version:"
python --version
pip freeze


echo "---------------------------------"
echo "dataClay2 creating city"
echo "---------------------------------"
# Note that dataClay2 uses dataClay1 folder also (change that to be less confusing)
ssh $REMOTE_NODE "source $VIRTUAL_ENV/bin/activate; cd ~/dataclay-class/examples/CLASSDemo/dataClay1/python; python src/create_city.py; deactivate"

echo "---------------------------------"
echo "dataClay1 creating Events"
echo "---------------------------------"
pushd $SCRIPTDIR/../../dataClay1/$LANG > /dev/null
python src/main.py
rc=$?; if [[ $rc != 0 ]]; then echo "FAIL"; exit $rc; else echo "OK"; fi 
popd > /dev/null

echo "---------------------------------"
echo "dataClay2 getting Events in city"
echo "---------------------------------"
ssh $REMOTE_NODE "source $VIRTUAL_ENV/bin/activate; cd ~/dataclay-class/examples/CLASSDemo/dataClay1/python; python src/get_events.py; deactivate"

echo "---------------------------------"
echo "dataClay1 unfederate blocks"
echo "---------------------------------"
pushd $SCRIPTDIR/../../dataClay1/$LANG > /dev/null
python src/unfederate.py
rc=$?; if [[ $rc != 0 ]]; then echo "FAIL"; exit $rc; else echo "OK"; fi 
popd > /dev/null

echo "---------------------------------"
echo "dataClay2 getting Events in city"
echo "---------------------------------"
ssh $REMOTE_NODE "source $VIRTUAL_ENV/bin/activate; cd ~/dataclay-class/examples/CLASSDemo/dataClay1/python; python src/get_events.py; deactivate"

echo ""
echo " #################################### " 
echo " DEMO FINISHED "
echo " #################################### " 

deactivate
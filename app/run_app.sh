#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLSBASE=$SCRIPTDIR/../tools/
TOOLSPATH="$TOOLSBASE/dClayTool.sh"
CLASSPATH="$TOOLSBASE/dataclayclient.jar:$TOOLSBASE/lib/*:lib/*"
LOG4JCONF=-Dlog4j.configurationFile=file:cfglog/log4j2.xml
#LOG4JCONF=-Dorg.apache.logging.log4j.simplelog.StatusLogger.level=OFF
REMOTE_NODE=$1 #ex: user@node
LOCAL_ADDR=$2 #ex 84.88.184.228:11034
REMOTE_ADDR=$3 #ex 84.88.51.177:11034
VIRTUAL_ENV=$4

echo " #################################### " 
echo " # RUNNING DEMO "
echo " #################################### " 
echo ""

# Export variables for demo
export DATACLAY1_ADDR=$LOCAL_ADDR
export DATACLAY2_ADDR=$REMOTE_ADDR


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
ssh $REMOTE_NODE "echo $VIRTUAL_ENV; source $VIRTUAL_ENV/bin/activate; cd ~/dataclay-class/app; python src/create_city.py; deactivate"

echo "---------------------------------"
echo "dataClay1 creating Events"
echo "---------------------------------"
python src/generate_events.py
rc=$?; if [[ $rc != 0 ]]; then echo "FAIL"; exit $rc; else echo "OK"; fi 

echo "---------------------------------"
echo "dataClay2 getting Events in city"
echo "---------------------------------"
ssh $REMOTE_NODE "source $VIRTUAL_ENV/bin/activate; cd ~/dataclay-class/app; python src/get_events.py; deactivate"

echo "---------------------------------"
echo "dataClay1 unfederate blocks"
echo "---------------------------------"
python src/unfederate.py
rc=$?; if [[ $rc != 0 ]]; then echo "FAIL"; exit $rc; else echo "OK"; fi 

echo "---------------------------------"
echo "dataClay2 getting Events in city"
echo "---------------------------------"
ssh $REMOTE_NODE "source $VIRTUAL_ENV/bin/activate; cd ~/dataclay-class/app; python src/get_events.py; deactivate"

echo ""
echo " #################################### " 
echo " DEMO FINISHED "
echo " #################################### " 

deactivate
#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLSBASE=$SCRIPTDIR/../../../../tools/
TOOLSPATH="$TOOLSBASE/dClayTool.sh"
CLASSPATH="$TOOLSBASE/dataclayclient.jar:$TOOLSBASE/lib/*:lib/*"
LOG4JCONF=-Dlog4j.configurationFile=file:cfglog/log4j2.xml
#LOG4JCONF=-Dorg.apache.logging.log4j.simplelog.StatusLogger.level=OFF
REMOTE_NODE=$1 #ex: user@node

LANG=$1
if [ $LANG == "java" ]; then
	CREATE_CITY="java $LOG4JCONF -cp stubs:bin:$CLASSPATH demo.CreateCity"
	GET_EVENTS="java $LOG4JCONF -cp stubs:bin:$CLASSPATH demo.GetEvents"
	MAIN="java $LOG4JCONF -cp stubs:bin:$CLASSPATH demo.Main"
	UNFEDERATE="java $LOG4JCONF -cp stubs:bin:$CLASSPATH demo.Unfederate"
else
	CREATE_CITY="python src/create_city.py"
	GET_EVENTS="python src/get_events.py"
	MAIN="python src/main.py"
	UNFEDERATE="python src/unfederate.py"
fi

echo " #################################### " 
echo " # RUNNING DEMO "
echo " #################################### " 
echo ""

# Export variables for demo
export DATACLAY1_IP=10.20.30.1
export DATACLAY1_PORT=1034
export DATACLAY2_IP=10.20.30.3
export DATACLAY2_PORT=1034

echo "---------------------------------"
echo "dataClay2 creating city"
echo "---------------------------------"
# Note that dataClay2 uses dataClay1 folder also (change that to be less confusing)
results=$(ssh $REMOTE_NODE "cd $SCRIPTDIR/../../dataClay1/$LANG > /dev/null; eval $CREATE_CITY)
rc=$?; if [[ $rc != 0 ]]; then echo "FAIL"; exit $rc; else echo "OK"; fi 
popd > /dev/null

echo "---------------------------------"
echo "dataClay1 creating Events"
echo "---------------------------------"
pushd $SCRIPTDIR/../../dataClay1/$LANG > /dev/null
eval $MAIN 
rc=$?; if [[ $rc != 0 ]]; then echo "FAIL"; exit $rc; else echo "OK"; fi 
popd > /dev/null

echo "---------------------------------"
echo "dataClay2 getting Events in city"
echo "---------------------------------"
results=$(ssh $REMOTE_NODE "cd $SCRIPTDIR/../../dataClay1/$LANG > /dev/null; eval $GET_EVENTS)
rc=$?; if [[ $rc != 0 ]]; then echo "FAIL"; exit $rc; else echo "OK"; fi 
echo $results
popd > /dev/null

echo "---------------------------------"
echo "dataClay1 unfederate blocks"
echo "---------------------------------"
pushd $SCRIPTDIR/../../dataClay1/$LANG > /dev/null
eval $UNFEDERATE 
rc=$?; if [[ $rc != 0 ]]; then echo "FAIL"; exit $rc; else echo "OK"; fi 
popd > /dev/null

echo "---------------------------------"
echo "dataClay2 getting Events in city"
echo "---------------------------------"
results=$(ssh $REMOTE_NODE "cd $SCRIPTDIR/../../dataClay1/$LANG > /dev/null; eval $GET_EVENTS)
rc=$?; if [[ $rc != 0 ]]; then echo "FAIL"; exit $rc; else echo "OK"; fi 
echo $results
popd > /dev/null


echo ""
echo " #################################### " 
echo " DEMO FINISHED "
echo " #################################### " 

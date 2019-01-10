#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
COMMONDIR=$SCRIPTDIR/../common

bash $COMMONDIR/stopDataClaysAndClean.sh
bash $COMMONDIR/startDataClays.sh
bash $SCRIPTDIR/registerModel.sh
bash $COMMONDIR/deployFederation.sh 1 2 java #from 1 to 2
bash $COMMONDIR/getStubs.sh 1 java
bash $COMMONDIR/registerAccountsAndContracts.sh 2 java
bash $COMMONDIR/getStubs.sh 2 java
bash $SCRIPTDIR/buildApp.sh 1 
bash $SCRIPTDIR/buildApp.sh 2 
bash $COMMONDIR/runApp.sh java


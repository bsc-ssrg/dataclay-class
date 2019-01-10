#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
COMMONDIR=$SCRIPTDIR/../common
bash $COMMONDIR/stopDataClaysAndClean.sh
bash $COMMONDIR/startDataClays.sh
bash $SCRIPTDIR/registerModel.sh
bash $COMMONDIR/deployFederation.sh 1 2 python #from 1 to 2, 2 nodes
bash $COMMONDIR/getStubs.sh 1 python
bash $COMMONDIR/registerAccountsAndContracts.sh 2 python
bash $COMMONDIR/getStubs.sh 2 python
bash $COMMONDIR/runApp.sh python
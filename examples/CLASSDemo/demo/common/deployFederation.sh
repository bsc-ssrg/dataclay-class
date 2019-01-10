#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TOOLS_PATH=$SCRIPTDIR/../../../../tools/
ORIGIN_DC=$1
DEST_DC=$2
LANG=$3
DEPLOY_SCRIPT=deploy_federation_model.sh
if [ $LANG == "python" ]; then
 	LANG="pythonee"
 	DEPLOY_SCRIPT=deploy_federation_python_model.sh
fi

echo "** Deploying federation from $ORIGIN_DC to $DEST_DC"

bash $TOOLS_PATH/export_federate_model.sh dockers_logicmodule${ORIGIN_DC}_1 dockers_logicmodule${DEST_DC}_1
bash $TOOLS_PATH/$DEPLOY_SCRIPT dockers_ds1${LANG}${ORIGIN_DC}_1 dockers_ds1${LANG}${DEST_DC}_1

#!/bin/bash
DATACLAY_EE_ORIGIN_DOCKER_NAME=$1 # ex: dockers_ds1java1_1
DATACLAY_EE_DEST_DOCKER_NAME=$2 # ex: dockers_ds1java2_1
TMPDIR="$(mktemp -d)"

# COPY EXEC. CLASSES 
docker cp $DATACLAY_EE_ORIGIN_DOCKER_NAME:/usr/src/dataclay/execClasses/ $TMPDIR
docker cp $TMPDIR/execClasses/ $DATACLAY_EE_DEST_DOCKER_NAME:/usr/src/dataclay/execClasses/

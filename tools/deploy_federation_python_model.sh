#!/bin/bash
DATACLAY_EE_ORIGIN_DOCKER_NAME=$1 # ex: dockers_ds1java1_1
DATACLAY_EE_DEST_DOCKER_NAME=$2 # ex: dockers_ds1java2_1
TMPDIR="$(mktemp -d)"

# COPY EXEC. CLASSES 
docker cp $DATACLAY_EE_ORIGIN_DOCKER_NAME:/usr/src/app/deploy/ $TMPDIR
docker cp $TMPDIR/deploy/ $DATACLAY_EE_DEST_DOCKER_NAME:/usr/src/app/

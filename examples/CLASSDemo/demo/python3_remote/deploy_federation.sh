#!/bin/bash
DEST_SSH=$1 # ex: pi@claypi2 (user@host) 

# ============ #
# This script copy registered classes from current node to remote node, 
# which is necessary for dataClay federation.
# ============ #

DATACLAY_EE_DOCKER_NAME=dockers_ds1pythonee1_1

# == deploy python model === #

TMPDIR="$(mktemp -d)"
# copy python execution classes from a local docker into temporary dir
docker cp $DATACLAY_EE_DOCKER_NAME:/usr/src/app/deploy/ $TMPDIR
# copy to remote location 
ssh $DEST_SSH "rm -rf ~/deploy/"
scp -r $TMPDIR/deploy/ $DEST_SSH:~/ # creates a folder called deploy in home directory of destination node
# execute command in remote location to 'import' classes into remote dockers
ssh $DEST_SSH "docker cp ~/deploy/ $DATACLAY_EE_DOCKER_NAME:/usr/src/app/"

# == deploy java model (UNCOMMENT FOR JAVA TESTS, not this) === #

#DATACLAY_EE_DOCKER_NAME=dockers_ds1java1_1

#TMPDIR="$(mktemp -d)"
# copy python execution classes from a local docker into temporary dir
#docker cp $DATACLAY_EE_DOCKER_NAME:/usr/src/dataclay/execClasses/ $TMPDIR
# copy to remote location 
#scp -r $TMPDIR/execClasses/ $DEST_SSH # creates a folder called deploy in home directory of destination node
# execute command in remote location to 'import' classes into remote dockers
#ssh $DEST_SSH "docker cp ./deploy/ $DATACLAY_EE_DOCKER_NAME:/usr/src/dataclay/execClasses/"

# == export database information === #

DATACLAY_LM_DOCKER_NAME=dockers_logicmodule1_1

TMPDIR="$(mktemp -d)"
TMPDUMP="$TMPDIR/dump.sql"
TABLES="accessedimpl accessedprop type java_type python_type memoryfeature cpufeature langfeature archfeature prefetchinginfo implementation python_implementation java_implementation annotation property java_property python_property operation java_operation python_operation metaclass java_metaclass python_metaclass namespace"

# Dump LM database in current node
# The following names need to be changed in case we use different logicmodule's names
for table in $TABLES;
do
	docker exec -t $DATACLAY_LM_DOCKER_NAME sqlite3 "/tmp/dataclay/LM" ".dump $table" >> $TMPDUMP
done

# Export to remote node
ssh $DEST_SSH "rm ~/dump.sql"
sed -i 's/CREATE TABLE /CREATE TABLE IF NOT EXISTS /g' $TMPDUMP
scp $TMPDUMP $DEST_SSH:~/ # copy a file dump.sql to remote node
ssh $DEST_SSH "docker cp ~/dump.sql $DATACLAY_LM_DOCKER_NAME:/tmp/dataclay/dump.sql"
ssh $DEST_SSH "docker exec -t $DATACLAY_LM_DOCKER_NAME sqlite3 \"/tmp/dataclay/LM\" \".read /tmp/dataclay/dump.sql\""



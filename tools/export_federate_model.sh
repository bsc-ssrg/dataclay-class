#!/bin/bash
DATACLAY_LM_ORIGIN_DOCKER_NAME=$1 # ex: dockers_lmpostgres1_1
DATACLAY_LM_DEST_DOCKER_NAME=$2 # ex: dockers_lmpostgres2_1
TMPDIR="$(mktemp -d)"
TMPDUMP="$TMPDIR/dump.sql"
TABLES="accessedimpl accessedprop type java_type python_type memoryfeature cpufeature langfeature archfeature prefetchinginfo implementation python_implementation java_implementation annotation property java_property python_property operation java_operation python_operation metaclass java_metaclass python_metaclass namespace"

# Dump LM database 
for table in $TABLES;
do
	docker exec -t $DATACLAY_LM_ORIGIN_DOCKER_NAME sqlite3 "/tmp/dataclay/LM" ".dump $table" >> $TMPDUMP
done
sed -i 's/CREATE TABLE /CREATE TABLE IF NOT EXISTS /g' $TMPDUMP
docker cp $TMPDUMP $DATACLAY_LM_DEST_DOCKER_NAME:"/tmp/dataclay/dump.sql"
docker exec -t $DATACLAY_LM_DEST_DOCKER_NAME sqlite3 "/tmp/dataclay/LM" ".read /tmp/dataclay/dump.sql"


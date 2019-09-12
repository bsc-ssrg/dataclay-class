#!/bin/bash

REMOTE_NODE1=$1 #ex: user@node
REMOTE_NODE2=$2 #ex: user@node

# This script uses ssh, make sure you have ssh keys with the remote node!
echo "WARNING:  This script uses ssh, make sure you have ssh keys with the remote node! Current and remote node must have the same directory $HOME/dataclay-class"
echo "Usage: generate_certs.sh user@node1 user@node2"

if [ "$#" -ne 2 ]; then
	echo " ERROR: wrong number of arguments "
	exit -1
fi

echo " Cleaning previous certificates... "
rm -rf node1
rm -rf node2
rm -rf ca
ssh $REMOTE_NODE1 "cd ~/dataclay-class/dockers/traefik/cert; rm *" 
ssh $REMOTE_NODE2 "cd ~/dataclay-class/dockers/traefik/cert; rm *" 


echo " ===== Preparing CA ===== "
# Certificate authority is current node
mkdir -p ca
pushd ca
openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -subj "/C=ES/ST=CAT/O=BSC/CN=rootCA" -sha256 -days 1024 -out rootCA.crt
popd

# Create and sign certificates for node1
echo " ===== Creating and signing certificates for $REMOTE_NODE1 ===== "
mkdir -p node1
pushd node1
openssl genrsa -out agent.key 2048
openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt -in agent.key -out agent.pem
openssl req -new -sha256 -key agent.key -subj "/C=ES/ST=CAT/O=BSC/CN=proxy" -out agent.csr
# sign the certificate
openssl x509 -req -in agent.csr -CA ../ca/rootCA.crt -CAkey ../ca/rootCA.key -CAcreateserial -out agent.crt -days 500 -sha256
scp agent.pem $REMOTE_NODE1:~/dataclay-class/dockers/traefik/cert
scp agent.crt $REMOTE_NODE1:~/dataclay-class/dockers/traefik/cert
scp ../ca/rootCA.crt $REMOTE_NODE1:~/dataclay-class/dockers/traefik/cert
popd

echo " ===== Creating and signing certificates for $REMOTE_NODE2 ===== "
mkdir -p node2
pushd node2
openssl genrsa -out agent.key 2048
openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt -in agent.key -out agent.pem
openssl req -new -sha256 -key agent.key -subj "/C=ES/ST=CAT/O=BSC/CN=proxy" -out agent.csr
# sign the certificate
openssl x509 -req -in agent.csr -CA ../ca/rootCA.crt -CAkey ../ca/rootCA.key -CAcreateserial -out agent.crt -days 500 -sha256
scp agent.pem $REMOTE_NODE2:~/dataclay-class/dockers/traefik/cert
scp agent.crt $REMOTE_NODE2:~/dataclay-class/dockers/traefik/cert
scp ../ca/rootCA.crt $REMOTE_NODE2:~/dataclay-class/dockers/traefik/cert
popd


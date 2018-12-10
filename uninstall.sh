#!/bin/bash
DOCKER_COMPOSE=dockers/docker-compose.yml

grn=$'\e[1;32m'
blu=$'\e[1;34m'
end=$'\e[0m'

printMsg() {
  clear
  ACCUMMSG="  $ACCUMMSG\n  $1"
  printf "\n\n  ${blu}[dataClay Uninstaller]${end} \n  ${grn}$ACCUMMSG${end} \n\n\n"
}

# Shutdown any previous docker containers
printMsg "Shutting dataClay down [ if needed ]"
docker-compose -f $DOCKER_COMPOSE down

# Uninstall dockers
printMsg "Uninstalling dataClay Docker images"
docker rmi -f bscdataclay/logicmodule
docker rmi -f bscdataclay/dsjava
docker rmi -f bscdataclay/dspython

# Uninstall Python client lib
printMsg "Uninstalling Python client library"
pip uninstall dataclay

printMsg "\n  dataClay has been successfully uninstalled"

#!/bin/bash
DOCKER_COMPOSE=dockers/docker-compose.yml
DATACLAYTOOL=tools/dClayTool.sh
GRPCIO="1.10.1"

grn=$'\e[1;32m'
blu=$'\e[1;34m'
end=$'\e[0m'

printMsg() {
  #clear
  ACCUMMSG="  $ACCUMMSG\n  $1"
  printf "\n\n  ${blu}[dataClay Installer]${end} \n  ${grn}$ACCUMMSG${end} \n\n\n"
}

printMsg "Checking dependencies"

# Check Java installed 
if ! [ -x "$(command -v java)" ]; then
  printMsg "Error: Java not found. Please check it is installed and java command can be run" >&2
  exit 1
fi

version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
version1=$(echo "$version" | awk -F. '{printf("%03d%03d",$1,$2);}')
if [[ "$version1" < "001008" ]]; then
    printMsg "Error: Java version is not 1.8 or greater. Please install a newer version of Java"
    exit 1
fi

# Check python is installed
if ! [ -x "$(command -v python)" ]; then
  printMsg "Error: Python not found. Please check it is installed" >&2
  exit 1
fi

# Check pip is installed 
if ! [ -x "$(command -v pip)" ]; then
  printMsg "Error: Pip not found. Please check it is installed" >&2
  exit 1
fi

# Check dockers is installed 
if ! [ -x "$(command -v docker)" ]; then
  printMsg "Error: Docker command not found or not supported. Please check it is installed" >&2
  exit 1
fi

# Check docker-compose is installed
if ! [ -x "$(command -v docker-compose)" ]; then
  printMsg "Error: Docker-compose not found. Please check it is installed" >&2
  exit 1
fi

# Check dataClayTools exists
if [ ! -f $DATACLAYTOOL ]; then
  printMsg "Error: $DATACLAYTOOL not found. Please make sure it exists" >&2
  exit 1
fi

# Check grpcio dependency
OTHERGRPCIO=`find $HOME/.local -type d | grep grpcio | grep -v $GRPCIO`
if [ "x$OTHERGRPCIO" != "x" ]; then
  printMsg "Error: dataClay requires grpcio 1.10.1 but some other versions were found:\n\n  $OTHERGRPCIO"
  exit 1
fi

# Pull docker images
printMsg "Pulling docker images"
docker-compose -f $DOCKER_COMPOSE pull
if [ $? -ne 0 ]; then
    docker run hello-world
    if [ $? -ne 0 ]; then
        printMsg "Error: Cannot run Docker commands. Verify that your user is in group 'docker'"
    else
        printMsg "Error: Cannot pull Docker images. Please verify your user is in group 'docker' or contact support-dataclay@bsc.es."
    fi
    exit 1
fi

# Install Python client lib from PyPI
printMsg "Installing Python lib"
pip install dataclay==2.0.dev2

#Run examples
printMsg "Testing Java installation"
pushd examples/HelloPeople/java
#bash demo.sh
#Check if HelloPeople went OK
rc=$?
if [[ $rc != 0 ]]; then 
    printMsg "Java installation failed"
    exit $rc; 
fi
popd

printMsg "Testing Python installation"
pushd examples/HelloPeople/python
bash demo.sh
#Check if HelloPeople went OK
rc=$?
if [[ $rc != 0 ]]; then 
    printMsg "Python installation failed"
    exit $rc; 
fi
popd

printMsg "\n  Congratulations! dataClay has been successfully installed and tested"

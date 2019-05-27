#!/bin/bash
DATACLAYTOOL=tools/dClayTool.sh
GRPCIO="1.17.1"

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

# Check grpcio dependency
OTHERGRPCIO=`find $HOME/.local -type d | grep grpcio | grep -v $GRPCIO`
if [ "x$OTHERGRPCIO" != "x" ]; then
  printMsg "Error: dataClay requires grpcio 1.17.1 but some other versions were found:\n\n  $OTHERGRPCIO"
  exit 1
fi

printMsg "\n  Congratulations! dataClay dependencies are accomplished."

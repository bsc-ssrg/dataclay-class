# dataclay-class

Welcome! Here you will find some information in order to bootstrap a "dataClay environment"
You can use it to familiarize that with dataClay, to explore the different components, to run some demo 
applications based on the CLASS project, etc.

## Preflight check

You need:

  - **docker** Get it through https://www.docker.com/ > Get Docker
  - **docker-compose** Quickest way to get the latest release https://github.com/docker/compose/releases
  - **Python 3.5.x or 2.7.x**
  - **Java 8**

Also:
  - A python **virtualenv** for the previous interpreter is strongly suggested, but not required.
  
## Initializing the dataClay services

A `docker-compose.yml` is provided to ease the process. You can simply do:

    $> cd dockers
    $> docker-compose down # stop and clean previous containers
    $> docker-compose up

That will download and orchestrate the different images needed. Note that, 
by default, the dataClay LogicModule will be listening to port 11034.

**Do not Ctrl+C the process**. If you want the `docker-compose` to be in the
background, add the flag `-d` (detached mode). Otherwise, just leave that 
opened and proceed into a new terminal. For further options on `docker-compose`
process, read its documentation.

## Docker images for ARM 

You can find two docker composes to use dataClay in ARM, one will be using Python 2.7.x and the other one Python>=3.5.x
Simply do:

    $> cd dockers
    $> docker-compose -f docker-compose-arm.yml down # stop and clean previous containers
    $> docker-compose -f docker-compose-arm.yml up
    
## Executing dataClay CLASS demo examples

### Preparing the environment

dataClay CLASS demo needs two nodes so the first step will be to start dataClay 
in both nodes (see previous section).
Also, we must have SSH access configured (without querying password) between nodes in order
to execute the demo automatically. 

### Releasing extended dataClay docker images for CLASS

In order to avoid registering accounts, model, contracts, interfaces in each demo, we release in docker Hub 
an extension of a dataClay image with already registered models and accounts.

    $> cd model
    $> ./release.sh --push 
    
The script will release docker images for CLASS named `dataclayclass/logicmodule`, `dataclayclass/dsjava` `dataclayclass/dspython:py2.7`, `dataclayclass/dspython:py3.6`, `dataclayclass/logicmodule:arm`, `dataclayclass/dsjava:arm` `dataclayclass/dspython:arm-py2.7` and `dspython:arm-py3.6`

Make sure you have access to dataclayclass repository before running the script. If you would like to build
the images without pushing them to DockerHub just call `release.sh`without arguments. Remember that same 
image should be running in all nodes (with same accounts, contracts and models...)


### Running the demo

Once dataClay is running, we execute the run.sh script located in the root directory of the repository. 

  $node1> run.sh user@remote-node localAddr remoteAddr localDockerFile remoteDockerFile virtualEnv ssl?

where: 
- user@remote-node: Remote node ssh access 
- localIP: local IP address with dataClay logicmodule exposed port. ex 84.88.184.228:11034
- remoteIP: remote IP addres with dataClay logicmodule exposed port. ex 84.88.184.227:11034
- localDockerFile: path of docker file to be used in local. Ex: dockers/docker-compose.yml
- remoteDockerFile: path of docker file to be used in local. Ex: dockers/docker-compose-arm.yml
- virtualEnv: Python virtual environment with installed dataclay version.
REMEMBER that python version and dataclay version should be consistent with docker images being used.
- ssl?: can be true or false Indicates we want to use secure connections.

This script will use extended dataclay docker images for CLASS named `dataclayclass/logicmodule`, `dataclayclass/dsjava` and `dataclayclass/dspython` and run the application located at `app/src`

## Repository structure

- app: contains the demo application for CLASS 
- dockers: contains docker-compose files to orchestrate dataClay 
- model: contains docker files to build a specific CLASS docker image with dataClay
- tools: contains set of tools to register models and get stubs in dataClay 
- security: contains scripts to generate SSL certificates for secure dataClay connections

## dataClay documentation 

Further information about dataClay (usage, management, help) can be found at https://www.bsc.es/dataclay

## Acknowledgements

This work has been supported by the EU H2020 project CLASS, contract #780622.

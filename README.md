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

### Running the demo

Once dataClay is running, we execute the run.sh script located in the root directory of the repository. 

  $node1> run.sh user@node localIP remoteIP localDockerFile remoteDockerFile virtualEnv embeddedModel?

where: 
- localIP: local IP address
- remoteIP: remote IP addres
- localDockerFile: path of docker file to be used in local. Ex: dockers/docker-compose.yml
- remoteDockerFile: path of docker file to be used in local. Ex: dockers/docker-compose-arm.yml
- virtualEnv: Path to folder of python virtual environment to use to run application. Ex: $HOME/pyenv3.5/
REMEMBER that this python virtual env. should have dataclay installed (consistent version with docker image)
- embeddedModel?: must be true or false. Indicates if we are using embedded model in docker images (avoid registering model, for current demo is false).

This script will register the model located at `app/model` folder and run the application located at `app/src`

## Repository structure

- app: contains the demo application for CLASS 
- dockers: contains docker-compose files to orchestrate dataClay 
- model: contains docker files to build a specific CLASS docker image with dataclay
- tools: contains set of tools to register models and get stubs in dataclay 

## dataClay documentation 

Further information about dataClay (usage, management, help) can be found at https://www.bsc.es/dataclay

## Acknowledgements

This work has been supported by the EU H2020 project CLASS, contract #780622.

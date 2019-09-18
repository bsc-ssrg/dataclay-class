ARG DATACLAY_TAG
FROM bscdataclay/logicmodule:${DATACLAY_TAG}

COPY ./LM.sqlite /tmp/dataclay/LM

# The command can contain additional options for the Java Virtual Machine and
# must contain a class to be executed.
ENTRYPOINT ["java", "-cp", "dataclay.jar:lib/*", "-Dlog4j.configurationFile=/usr/src/dataclay/log4j2.xml", "dataclay.logic.server.LogicModuleSrv"]
# Don't use CMD in order to keep compatibility with singularity container's generator
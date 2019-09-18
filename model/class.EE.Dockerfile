ARG DATACLAY_TAG
FROM bscdataclay/dspython:${DATACLAY_TAG}

COPY ./deploy /usr/src/app/deploy

# Execute
# Don't use CMD in order to keep compatibility with singularity container's generator
ENTRYPOINT ["python", "-m", "dataclay.executionenv.server"]

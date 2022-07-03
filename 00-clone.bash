#!/bin/bash

VERSION=v0.0.8
REPO_NAME=nap-devops-gcp-infra

if [ $# -ne "1" ]; then
    echo "Arguments <dev|prod> are required!!!"
    exit 1
fi

ENVIRONMENT_ALIAS=$1
BRANCH=development
ENVIRONMENT=development

if [ "${ENVIRONMENT_ALIAS}" == "dev" ]; then
    BRANCH=development
    ENVIRONMENT=development
elif [ "${ENVIRONMENT_ALIAS}" == "prod" ]; then
    BRANCH=production
    ENVIRONMENT=production
fi

sudo docker run \
-v $(pwd)/${REPO_NAME}-${ENVIRONMENT}:/wip/output \
-v ${HOME}/.ssh/:/root/.ssh/ \
-e IASC_VCS_MODE=git \
-e IASC_VCS_URL="https://github.com/nap-devops/${REPO_NAME}.git" \
-e IASC_VCS_REF=${BRANCH} \
-e ENVIRONMENT_ALIAS=${ENVIRONMENT_ALIAS} \
-e ENVIRONMENT=${ENVIRONMENT} \
-it gcr.io/its-artifact-commons/iasc:${VERSION} \
init

sudo chown -R $(whoami):$(whoami) ${REPO_NAME}-${ENVIRONMENT}

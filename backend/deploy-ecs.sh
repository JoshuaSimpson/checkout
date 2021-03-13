#!/bin/bash

set -e

while getopts e:i:v: flag
do
    case "${flag}" in
        e) ENVIRONMENT=${OPTARG};;
        i) IMAGE_LOCATION=${OPTARG};;
        v) IMAGE_VERSION=${OPTARG};;
    esac
done

# # Define variables
TASK_FAMILY=api
SERVICE_NAME=api
CLUSTER_NAME=checkout-app

if [ -z "$ENVIRONMENT" ]; then
    echo "exit: No ENVIRONMENT specified"
    exit;
fi

if [ -z "$IMAGE_LOCATION" ]; then
    echo "exit: No IMAGE_LOCATION specified"
    exit;
fi

if [ -z "$IMAGE_VERSION" ]; then
    echo "exit: No IMAGE_VERSION specified"
    exit;
fi

ENVIRONMENT_PLACEHOLDER="<ENVIRONMENT>"
IMAGE_PLACEHOLDER="<IMAGE>"
VERSION_PLACEHOLDER="<VERSION>"

CONTAINER_DEFINITION_FILE=$(cat ./container-definition.json)
CONTAINER_DEFINITION="${CONTAINER_DEFINITION_FILE//$ENVIRONMENT_PLACEHOLDER/$ENVIRONMENT}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//$IMAGE_PLACEHOLDER/$IMAGE_LOCATION}"
CONTAINER_DEFINITION="${CONTAINER_DEFINITION//$VERSION_PLACEHOLDER/$IMG_VERSION}"

echo $CONTAINER_DEFINITION

export TASK_VERSION=$(aws ecs register-task-definition --family ${TASK_FAMILY} --container-definitions "$CONTAINER_DEFINITION" | jq --raw-output '.taskDefinition.revision')
echo "Registered ECS Task Definition: " $TASK_VERSION


if [ -n "$TASK_VERSION" ]; then
    echo "Update ECS Cluster: " $CLUSTER_NAME
    echo "Service: " $SERVICE_NAME
    echo "Task Definition: " $TASK_FAMILY:$TASK_VERSION
    
    DEPLOYED_SERVICE=$(aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $TASK_FAMILY:$TASK_VERSION | jq --raw-output '.service.serviceName')
    echo "Deployment of $DEPLOYED_SERVICE complete"

else
    echo "exit: No task definition"
    exit;
fi
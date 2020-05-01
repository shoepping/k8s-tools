#!/bin/bash

USERNAME=${1}
PASSWORD=${2}
ENVIRONMENT=${3}
PORT=${4}
IP_ADDRESS_RESOURCE_GROUP=${5}
IP_NAME=${6}
RESOURCE_GROUP_TAG=${7}
NAMESPACE=${8}
CLUSTER_NAME=${NAMESPACE}

az login \
    -u ${USERNAME} \
    -p ${PASSWORD}

# get resource group for ip
RESOURCE_GROUP=$(
    az network public-ip show \
        --resource-group ${IP_ADDRESS_RESOURCE_GROUP} \
        --name ${IP_NAME} \
        --query "ipConfiguration.resourceGroup" -o tsv)

# get tag
RESOURCE_GROUP=$(
    az group show \
        --name ${RESOURCE_GROUP} \
        --query "tags.${RESOURCE_GROUP_TAG}" -o tsv)

az aks get-credentials \
    --resource-group ${RESOURCE_GROUP} \
	--name ${CLUSTER_NAME}

echo "K8s Dashboard: http://localhost:${PORT}/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/#!/overview?namespace=${NAMESPACE}"
echo ""

az aks browse \
    --listen-address 0.0.0.0 \
    --resource-group ${RESOURCE_GROUP} \
    --name ${CLUSTER_NAME}


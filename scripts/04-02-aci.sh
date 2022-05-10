# Source: https://gist.github.com/6d6041896ef1243233c11b51d082eb6e

# Pre-requisites: https://gist.github.com/34009f4c65683dd3a82081fa8d76cd85

az acr login --name $REGISTRY_NAME

docker image pull \
    vfarcic/devops-toolkit-series

export IMAGE=$REGISTRY_NAME.azurecr.io/devops-toolkit-series:0.0.1

docker image tag \
    vfarcic/devops-toolkit-series \
    $IMAGE

docker image push $IMAGE

az acr repository list \
    --name $REGISTRY_NAME \
    --output table

az acr repository show-tags \
    --name $REGISTRY_NAME \
    --repository devops-toolkit-series \
    --output table

echo $REGISTRY_NAME

open https://portal.azure.com

export SUBDOMAIN=devopstoolkitseries$(date +%Y%m%d%H%M%S)

az acr credential show \
    --name $REGISTRY_NAME

export ACR_USER=$(
    az acr credential show \
    --name $REGISTRY_NAME \
    | jq -r '.username')

export ACR_PASS=$(
    az acr credential show \
    --name $REGISTRY_NAME \
    | jq -r '.passwords[0].value')

az container create \
    --resource-group $RESOURCE_GROUP \
    --name devops-toolkit-series \
    --location $REGION \
    --image $IMAGE \
    --dns-name-label $SUBDOMAIN \
    --ports 80 \
    --registry-username $ACR_USER \
    --registry-password $ACR_PASS

az container show \
    --resource-group $RESOURCE_GROUP \
    --name devops-toolkit-series \
    --out table

export ADDR=http://$SUBDOMAIN.$REGION.azurecontainer.io

open $ADDR

kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 1000 --time 30S "$ADDR"

kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 1000 --time 30S "$ADDR"

az container delete \
    --resource-group $RESOURCE_GROUP \
    --name devops-toolkit-series

docker login azure

docker context create aci aci \
    --location $REGION \
    --resource-group $RESOURCE_GROUP

docker context use aci

docker context list

echo "version: \"3.8\"
services:
  frontend:
    image: vfarcic/devops-toolkit-series
    ports:
      - \"80:80\"" \
    | tee docker-compose.yaml

docker compose up \
    --project-name devops-toolkit-series

docker ps

docker inspect \
    devops-toolkit-series_frontend

export IP=$(docker inspect \
    devops-toolkit-series_frontend \
    | jq -r ".Ports[0].HostIP")

export PORT=$(docker inspect \
    devops-toolkit-series_frontend \
    | jq -r ".Ports[0].HostPort")

export ADDR=http://$IP:$PORT

open $ADDR

docker exec -it \
    devops-toolkit-series_frontend sh

exit

docker compose down \
    --project-name devops-toolkit-series

docker context rm aci --force

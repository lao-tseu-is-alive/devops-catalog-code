# Source: https://gist.github.com/59f647c62db7502a2ad9e21210f38c63

# Pre-requisites: https://gist.github.com/2aa8ee4a6451fd762b1a10799bbeac88

gcloud auth configure-docker

docker image pull \
    vfarcic/devops-toolkit-series

export IMAGE=gcr.io/$PROJECT_ID/devops-toolkit-series:0.0.1

docker image tag \
    vfarcic/devops-toolkit-series \
    $IMAGE

docker image push $IMAGE

gcloud container images list \
    --project $PROJECT_ID

open https://console.cloud.google.com/gcr/images/$PROJECT_ID

export REGION=us-east1

gcloud run deploy \
    devops-toolkit-series \
    --image $IMAGE \
    --region $REGION \
    --allow-unauthenticated \
    --port 80 \
    --concurrency 100 \
    --platform managed \
    --project $PROJECT_ID

gcloud run services list \
    --region $REGION \
    --platform managed \
    --project $PROJECT_ID

gcloud run revisions list \
    --region $REGION \
    --platform managed \
    --project $PROJECT_ID

gcloud run services describe \
    devops-toolkit-series \
    --region $REGION \
    --platform managed \
    --project $PROJECT_ID \
    --format yaml

export ADDR=$(gcloud run services \
    describe devops-toolkit-series \
    --region $REGION \
    --platform managed \
    --project $PROJECT_ID \
    --format json \
    | jq -r ".status.url")

open $ADDR

open https://console.cloud.google.com/run?project=$PROJECT_ID

kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 1000 --time 30S "$ADDR"

kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 1000 --time 30S "$ADDR"

gcloud run services \
    delete devops-toolkit-series \
    --region $REGION \
    --platform managed \
    --project $PROJECT_ID

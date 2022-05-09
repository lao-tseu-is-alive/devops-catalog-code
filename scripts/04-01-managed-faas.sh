# Source: https://gist.github.com/5d309852d42475202f4cfb6fdf4e8894

curl -o- -L https://slss.io/install \
    | bash

exit

# Open a new terminal session

serverless create --help

##########################################
# Deploying Google Cloud Functions (GCF) #
##########################################

# Pre-requisites: https://gist.github.com/a18d6b7bf6ec9516a6af7aa3bd27d7c9

serverless create \
    --template google-nodejs \
    --path gcp-function

cd gcp-function

ls -1

cat index.js

cat package.json

cat serverless.yml

cat serverless.yml \
    | sed -e "s@us-central1@$REGION@g" \
    | sed -e "s@my-project@$PROJECT_ID@g" \
    | sed -e "s@~/.gcloud/keyfile.json@$PATH_TO_ACCOUNT_JSON@g" \
    | tee serverless.yml

# If using Ubuntu (including WSL) and it you do not already have npm
sudo apt update && \
    sudo apt install nodejs npm

# If you are a macOS user, and you do not already have npm
open https://nodejs.org/en/download/

npm install

serverless deploy

serverless invoke --function first

serverless info

export ADDR=[...]

curl $ADDR

gcloud functions \
    add-iam-policy-binding \
    gcp-function-dev-first \
    --member "allUsers" \
    --role "roles/cloudfunctions.invoker" \
    --region $REGION \
    --project $PROJECT_ID

curl $ADDR

kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 1000 --time 30S "$ADDR"

kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 1000 --time 30S "$ADDR"

open "https://console.cloud.google.com/functions/list?project=$PROJECT_ID"

serverless remove

cd ..

rm -rf gcp-function

##################################
# Deploying Azure Functions (AF) #
##################################

# Pre-requisites: https://gist.github.com/432db6a1ee651834aee7ef5ec4c91eee

serverless create \
    --template azure-nodejs \
    --path azure-function

cd azure-function

ls -1

ls -1 src/handlers

cat src/handlers/hello.js

cat package.json

cat serverless.yml

export PREFIX=$(date +%Y%m%d%H%M%S)

cat serverless.yml \
    | sed -e "s@West US 2@$REGION@g" \
    | sed -e "s@nodejs12.x@nodejs12@g" \
    | sed -e "s@# os@subscriptionId: $AZURE_SUBSCRIPTION_ID\\
  resourceGroup: $RESOURCE_GROUP\\
  prefix: \"$PREFIX\"\\
  # os@g" \
    | tee serverless.yml

# If using Ubuntu (including WSL) and it you do not already have npm
sudo apt update && \
    sudo apt install nodejs npm

# If you are a macOS user, and you do not already have npm
open https://nodejs.org/en/download/

npm install

serverless plugin list | grep azure

serverless plugin install \
    --name serverless-azure-functions

az account set -s $AZURE_SUBSCRIPTION_ID

export SERVICE_PRINCIPAL=$(\
    az ad sp create-for-rbac)

echo $SERVICE_PRINCIPAL

export AZURE_TENANT_ID=$(
    echo $SERVICE_PRINCIPAL | \
    jq ".tenant")

export AZURE_CLIENT_ID=$(
    echo $SERVICE_PRINCIPAL | \
    jq ".name")

export AZURE_CLIENT_SECRET=$(
    echo $SERVICE_PRINCIPAL | \
    jq ".password")

echo "export AZURE_TENANT_ID=$AZURE_TENANT_ID
export AZURE_CLIENT_ID=$AZURE_CLIENT_ID
export AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET" \
    | tee creds

echo "

/creds" | tee -a .gitignore

source creds

serverless deploy

serverless invoke \
    --function hello \
    --data '{"name": "Viktor"}'

serverless info

export FUNC_NAME=[...]

export ADDR=http://$FUNC_NAME.azurewebsites.net/api/hello?name=Viktor

curl $ADDR

kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 1000 --time 30S "$ADDR"

kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 1000 --time 30S "$ADDR"

open "https://portal.azure.com"

serverless remove

cd ..

rm -rf azure-function

########################
# Deploying AWS Lambda #
########################

serverless create \
    --template aws-nodejs \
    --path aws-function

cd aws-function

ls -1

cat handler.js

cat serverless.yml

cat serverless.yml \
    | sed -e "s@handler.hello@handler.hello\\
    events:\\
      - http:\\
          path: hello\\
          method: get@g" \
    | tee serverless.yml

export AWS_ACCESS_KEY_ID=[...]

export AWS_SECRET_ACCESS_KEY=[...]

echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
    | tee creds

echo "
/creds" | tee -a .gitignore

source creds

serverless deploy

serverless invoke --function hello

serverless info

export ADDR=[...]

curl $ADDR

open https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions

serverless remove

cd ..

rm -rf aws-function

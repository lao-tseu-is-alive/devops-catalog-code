# Source: https://gist.github.com/c9e05ce1b744c0aad5d10ee5158099fa

###############################
# Preparing For The Exercises #
###############################

git clone \
    https://github.com/vfarcic/devops-catalog-code.git

cd devops-catalog-code

git pull

# Docker Desktop (docker.sh): https://gist.github.com/9f2ee2be882e0f39474d1d6fb1b63b83
# Minikube (minikube.sh): https://gist.github.com/2a6e5ad588509f43baa94cbdf40d0d16
# GKE (gke.sh): https://gist.github.com/68e8f17ebb61ef3be671e2ee29bfea70
# EKS (eks.sh): https://gist.github.com/200419b88a75f7a51bfa6ee78f0da592
# AKS (aks.sh): https://gist.github.com/0e28b2a9f10b2f643502f80391ca6ce8

# Make sure that you have Helm CLI v3+ installed

cd helm

########################
# Creating Helm Charts #
########################

helm create my-app

ls -1 my-app

rm -rf my-app

ls -1 go-demo-9

cat go-demo-9/Chart.yaml

ls -1 go-demo-9/templates

cat go-demo-9/templates/deployment.yaml

cat go-demo-9/values.yaml

cat go-demo-9/templates/ingress.yaml

cat go-demo-9/values.yaml

cat go-demo-9/templates/hpa.yaml

cat go-demo-9/values.yaml

###################################
# Adding Application Dependencies #
###################################

cat go-demo-9/requirements.yaml

helm repo add stable \
    https://charts.helm.sh/stable

helm search repo mongodb

helm show readme stable/mongodb

helm repo add bitnami \
    https://charts.bitnami.com/bitnami

helm repo list

helm search repo mongodb

cat go-demo-9/requirements.yaml

helm show values bitnami/mongodb \
  --version 7.13.0

cat go-demo-9/values.yaml

########################################
# Deploying Applications To Production #
########################################

kubectl create namespace production

helm dependency list go-demo-9

helm dependency update go-demo-9

helm dependency list go-demo-9

helm --namespace production \
    upgrade --install \
    go-demo-9 go-demo-9 \
    --wait \
    --timeout 10m

helm --namespace production list

kubectl --namespace production \
    get ingresses

curl -H "Host: go-demo-9.acme.com" \
    "http://$INGRESS_HOST"

kubectl --namespace production \
    get hpa

kubectl get persistentvolumes

##################################################################
# Deploying Applications To Development And Preview Environments #
##################################################################

export GH_USER=[...]

kubectl create namespace $GH_USER

cat go-demo-9/values.yaml

cat dev/values.yaml

export ADDR=$GH_USER.go-demo-9.acme.com

helm --namespace $GH_USER \
    upgrade --install \
    --values dev/values.yaml \
    --set ingress.host=$ADDR \
    go-demo-9 go-demo-9 \
    --wait \
    --timeout 10m

kubectl --namespace $GH_USER \
    get ingresses

curl -H "Host: $ADDR" \
    "http://$INGRESS_HOST"

kubectl --namespace $GH_USER \
    get hpa

kubectl --namespace $GH_USER \
    get pods

kubectl get persistentvolumes

helm --namespace $GH_USER \
    delete go-demo-9

kubectl delete namespace $GH_USER

###################################################################
# Deploying Applications To Permanent Non-Production Environments #
###################################################################

kubectl create namespace staging

cat staging/values.yaml

helm --namespace staging \
    upgrade --install \
    --values staging/values.yaml \
    go-demo-9 go-demo-9 \
    --wait \
    --timeout 10m

kubectl --namespace staging \
    get ingresses

curl -H "Host: staging.go-demo-9.acme.com" \
    "http://$INGRESS_HOST"

kubectl --namespace staging \
    get hpa

kubectl get persistentvolumes

####################################
# Packaging And Deploying Releases #
####################################

git checkout -b my-new-feature

cat go-demo-9/Chart.yaml

cat go-demo-9/Chart.yaml \
    | sed -e "s@version: 0.0.1@version: 0.0.2@g" \
    | sed -e "s@appVersion: 0.0.1@appVersion: 0.0.2@g" \
    | tee go-demo-9/Chart.yaml

cat go-demo-9/values.yaml

cat go-demo-9/values.yaml \
    | sed -e "s@tag: 0.0.1@tag: 0.0.2@g" \
    | tee go-demo-9/values.yaml

helm lint go-demo-9

helm package go-demo-9

helm --namespace production \
    upgrade --install \
    go-demo-9 go-demo-9-0.0.2.tgz \
    --wait \
    --timeout 10m

helm --namespace production list

helm --namespace production \
    get all go-demo-9

curl -H "Host: go-demo-9.acme.com" \
    "http://$INGRESS_HOST"

#########################
# Rolling Back Releases #
#########################

helm --namespace production \
    history go-demo-9

helm --namespace production \
    rollback go-demo-9

helm --namespace production \
    history go-demo-9

helm --namespace production \
    status go-demo-9

curl -H "Host: go-demo-9.acme.com" \
    "http://$INGRESS_HOST"

############################
# Destroying The Resources #
############################

git stash

git checkout master

git branch -d my-new-feature

kubectl delete namespace staging

kubectl delete namespace production

cd ../

cd ../

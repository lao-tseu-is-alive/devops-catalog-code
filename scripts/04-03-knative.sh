# Source: https://gist.github.com/dc4ba562328c1d088047884026371f1f

###########################################################
# Using Knative To Deploy And Manage Serverless Workloads #
###########################################################

######################
# Installing Knative #
######################

# GKE (gke-simple.sh): https://gist.github.com/ebe4ad31d756b009b2e6544218c712e4)
# EKS (eks-simple.sh): https://gist.github.com/8ef7f6cb24001e240432cd6a82a515fd)
# AKS (aks-simple.sh): https://gist.github.com/f3e6575dcefcee039bb6cef6509f3fdc)

kubectl apply \
    --filename https://github.com/knative/serving/releases/download/knative-v1.4.0/serving-crds.yaml

kubectl apply \
    --filename https://github.com/knative/serving/releases/download/knative-v1.4.0/serving-core.yaml

kubectl --namespace knative-serving \
    get pods

git clone \
    https://github.com/vfarcic/devops-catalog-code.git

cd devops-catalog-code

git pull

cd knative/istio

istioctl install --skip-confirmation

kubectl --namespace istio-system \
    get pods

kubectl label namespace knative-serving \
    istio-injection=enabled

cat peer-auth.yaml

kubectl apply --filename peer-auth.yaml

# Only if GKE or AKS
export INGRESS_IP=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Only if GKE or AKS
export INGRESS_HOST=$INGRESS_IP.nip.io

# Only if EKS
export INGRESS_HOST=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')

kubectl --namespace knative-serving \
    get configmap config-domain \
    --output yaml

echo "apiVersion: v1
kind: ConfigMap
metadata:
  name: config-domain
  namespace: knative-serving
data:
  $INGRESS_HOST: \"\" 
" | kubectl apply --filename -

kubectl --namespace knative-serving \
    get pods

############################
# Painting The Big Picture #
############################

kubectl create namespace production

kubectl label namespace production \
    istio-injection=enabled

kn service create devops-toolkit \
    --namespace production \
    --image vfarcic/devops-toolkit-series \
    --port 80

kubectl --namespace production \
    get routes

# Only if EKS
curl -H "Host: devops-toolkit.production.example.com" \
    http://$INGRESS_HOST

# Only if GKE or AKS
open http://devops-toolkit.production.$INGRESS_HOST

kubectl --namespace production \
    get pods

# Only if EKS
curl -H "Host: devops-toolkit.production.example.com" \
    http://$INGRESS_HOST

# Only if GKE or AKS
open http://devops-toolkit.production.$INGRESS_HOST

kn service delete devops-toolkit \
    --namespace production

#########################################
# Defining Knative Applications As Code #
#########################################

cat devops-toolkit.yaml

kubectl --namespace production apply \
    --filename devops-toolkit.yaml

# Only if EKS
curl -H "Host: devops-toolkit.production.example.com" \
    http://$INGRESS_HOST

# Only if GKE or AKS
open http://devops-toolkit.production.$INGRESS_HOST

kubectl --namespace production \
    get kservice

kubectl --namespace production \
    get configuration

kubectl --namespace production \
    get revisions

kubectl --namespace production \
    get deployments

kubectl --namespace production \
    get services,virtualservices

kubectl --namespace production \
    get podautoscalers

kubectl --namespace production \
    get routes

# Only if EKS
kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 500 --time 60S \
    --header "Host: devops-toolkit.production.example.com" \
    "http://$INGRESS_HOST" \
    && kubectl --namespace production \
    get pods

# Only if GKE or AKS
kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 500 --time 60S \
    "http://devops-toolkit.production.$INGRESS_HOST" \
    && kubectl --namespace production \
    get pods

kubectl --namespace production \
    get pods

############################
# Destroying The Resources #
############################

kubectl --namespace production delete \
    --filename devops-toolkit.yaml

kubectl delete namespace production

cd ../../../

# Only if EKS
kubectl --namespace istio-system \
    delete service istio-ingressgateway

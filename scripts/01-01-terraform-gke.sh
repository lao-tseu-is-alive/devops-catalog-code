# Source: https://gist.github.com/c83d74ec70b68629b691bab52f5553a6

###############################
# Preparing For The Exercises #
###############################

git clone \
    https://github.com/vfarcic/devops-catalog-code.git

cd devops-catalog-code

git pull

cd terraform-gke

#################################
# Exploring Terraform Variables #
#################################

cp files/variables.tf .

cat variables.tf

############################
# Creating The Credentials #
############################

gcloud auth application-default login

export PROJECT_ID=doc-$(date +%Y%m%d%H%M%S)

gcloud projects create $PROJECT_ID

gcloud projects list

gcloud iam service-accounts \
    create devops-catalog \
    --project $PROJECT_ID \
    --display-name devops-catalog

gcloud iam service-accounts list \
    --project $PROJECT_ID

gcloud iam service-accounts \
    keys create account.json \
    --iam-account devops-catalog@$PROJECT_ID.iam.gserviceaccount.com \
    --project $PROJECT_ID

gcloud iam service-accounts \
    keys list \
    --iam-account devops-catalog@$PROJECT_ID.iam.gserviceaccount.com \
    --project $PROJECT_ID

gcloud projects \
    add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:devops-catalog@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/owner

export TF_VAR_project_id=$PROJECT_ID

#########################
# Defining The Provider #
#########################

cp files/provider.tf .

cat provider.tf

terraform apply

terraform init

terraform apply

#########################################
# Storing The State In A Remote Backend #
#########################################

cat terraform.tfstate 

open https://console.cloud.google.com/storage/browser?project=$PROJECT_ID

cp files/storage.tf .

cat storage.tf

export TF_VAR_state_bucket=doc-$(date +%Y%m%d%H%M%S)

terraform apply

gsutil ls -p $PROJECT_ID

terraform show

cat terraform.tfstate

cp files/backend.tf .

cat backend.tf

export BUCKET_NAME=doc-$(date +%Y%m%d%H%M%S)

cat backend.tf \
  | sed -e "s@devops-catalog@$TF_VAR_state_bucket@g" \
  | tee backend.tf

terraform apply

terraform init

terraform apply

##############################
# Creating The Control Plane #
##############################

cp files/k8s-control-plane.tf .

cat k8s-control-plane.tf

terraform apply

gcloud container get-server-config \
    --region us-east1 \
    --project $PROJECT_ID

export K8S_VERSION=[...]

terraform apply \
    --var k8s_version=$K8S_VERSION

###############################
# Exploring Terraform Outputs #
###############################

cp files/output.tf .

cat output.tf

terraform refresh \
    --var k8s_version=$K8S_VERSION

terraform output cluster_name

export KUBECONFIG=$PWD/kubeconfig

gcloud container clusters \
    get-credentials \
    $(terraform output cluster_name) \
    --project \
    $(terraform output project_id) \
    --region \
    $(terraform output region)

kubectl create clusterrolebinding \
    cluster-admin-binding \
    --clusterrole \
    cluster-admin \
    --user \
    $(gcloud config get-value account)

kubectl get nodes

#########################
# Creating Worker Nodes #
#########################

cp files/k8s-worker-nodes.tf .

cat k8s-worker-nodes.tf

terraform apply \
    --var k8s_version=$K8S_VERSION

kubectl get nodes

#########################
# Upgrading The Cluster #
#########################

kubectl version --output yaml

gcloud container get-server-config \
    --region \
    $(terraform output region) \
    --project \
    $(terraform output project_id)

export K8S_VERSION=[...]

terraform apply \
    --var k8s_version=$K8S_VERSION

kubectl version --output yaml

################################
# Reorganizing The Definitions #
################################

rm -f *.tf

cat \
    files/backend.tf \
    files/k8s-control-plane.tf \
    files/k8s-worker-nodes.tf \
    files/provider.tf \
    files/storage.tf \
    | tee main.tf

cp files/variables.tf .

cat variables.tf

cp files/output.tf .

cat output.tf

terraform apply \
    --var k8s_version=$K8S_VERSION

############################
# Destroying The Resources #
############################

terraform destroy \
    --var k8s_version=$K8S_VERSION

cd ../../

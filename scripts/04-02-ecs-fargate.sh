# Source: https://gist.github.com/2ef4e1933d7c46fb1ddc41a633e1e7c7

# Pre-requisites: https://gist.github.com/fa047ab7bb34fdd185a678190798ef47

git clone \
    https://github.com/vfarcic/devops-catalog-code.git

cd devops-catalog-code

git pull

cd terraform-ecs-fargate/app

ls -1

cat variables.tf

cat main.tf

cat devops-toolkit-series.json

terraform init

terraform apply \
    --var lb_arn=$LB_ARN \
    --var security_group_id=$SECURITY_GROUP_ID \
    --var subnet_ids="$SUBNET_IDS" \
    --var cluster_id=$CLUSTER_ID

aws ecs list-services \
    --cluster $CLUSTER_ID

aws ecs list-tasks \
    --cluster $CLUSTER_ID

open http://$DNS

open https://console.aws.amazon.com/ecs/home?region=us-east-1

kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 1000 --time 30S "http://$DNS"

kubectl run siege \
    --image yokogawa/siege \
    -it --rm \
    -- --concurrent 1000 --time 30S "http://$DNS"

terraform destroy \
    --var lb_arn=$LB_ARN \
    --var security_group_id=$SECURITY_GROUP_ID \
    --var subnet_ids="$SUBNET_IDS" \
    --var cluster_id=$CLUSTER_ID

cd ../../../

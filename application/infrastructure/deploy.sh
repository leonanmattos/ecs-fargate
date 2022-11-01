#!/bin/sh

REGION="sa-east-1"
SERVICE_NAME="application"
SERVICE_TAG="1.0"
ECR_REPO_URL="970004148654.dkr.ecr.sa-east-1.amazonaws.com/${SERVICE_NAME}"

if [ "$1" = "build" ];then
    cd ..
    sh mvnw clean install
elif [ "$1" = "test" ];then
    echo $SERVICE_NAME
    find ../target/ -type f \( -name "*.jar" -not -name "*sources.jar" \) -exec cp {} ../infrastructure/$SERVICE_NAME.jar \;
elif [ "$1" = "dockerize" ];then
    find ../target/ -type f \( -name "*.jar" -not -name "*sources.jar" \) -exec cp {} ../infrastructure/$SERVICE_NAME.jar \;
    aws ecr create-repository --repository-name ${SERVICE_NAME:?} --region ${REGION} || true
    aws ecr get-login-password --region ${REGION}

    cd infrastructure
    docker build -t ${SERVICE_NAME}:${SERVICE_TAG} .
    docker tag ${SERVICE_NAME}:${SERVICE_TAG} ${ECR_REPO_URL}:${SERVICE_TAG}
    docker push ${ECR_REPO_URL}:${SERVICE_TAG}
elif [ "$1" = "plan" ];then
    cd infrastructure
    terraform init -backend-config="app-prod.config"
    terraform plan -var-file="production.tfvars" -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG"
elif [ "$1" = "deploy" ];then
    cd infrastructure
    terraform init -backend-config="app-prod.config"
    terraform apply -var-file="production.tfvars" -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG" -auto-approve
elif [ "$1" = "destroy" ];then
    cd infrastructure
    terraform init -backend-config="app-prod.config"
    terraform destroy -var-file="production.tfvars" -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG" -auto-approve
fi

#!/usr/local/bin/bash

BASE_NAME="chaos-testing-example"
TARGET_REGION="us-west-2"
TARGET_ENVIRONMENT="sbx"
BUCKET_NAME="sbx-chaos-testing-example-state-us-west-2"

usage() {
    echo "<deploy|destroy|test>"
}

terraformDeploy() {
  echo "terraformDeploy - 1"

  terraform init
  bucketImportStatus=$(terraform import -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars aws_s3_bucket_public_access_block.terraform_state ${BUCKET_NAME})
  echo "------------------"
  echo $bucketImportStatus
  bucketPublicAccessBlockImportStatus=$(terraform import -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars aws_s3_bucket_public_access_block.terraform_state ${BUCKET_NAME})
  echo "------------------"
  echo $bucketPublicAccessBlockImportStatus

  if [[ -n $bucketImportStatus || -n $bucketPublicAccessBlockImportStatus ]]; then
    echo "The terraform S3 backend could not be imported, so one will now be created."

    terraformPlanOutputFile="$(pwd)/out.plan"
    echo "%%%%%%%%%%%%%%%%%%%%%"
    echo ${terraformPlanOutputFile}
    echo "1 ------------------"
    terraform plan -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars -out="${terraformPlanOutputFile}"
    echo "2 ------------------"
    terraform apply -auto-approve -lock=true "${terraformPlanOutputFile}"
  else
    echo "An existing remote backend has been detected successfully."
    echo "Re-initializing using the detected remote backend."
  fi
}

terraformDestroy() {
  echo "terraformDestroy - 1"
  terraform init
  bucketImportStatus=$(terraform import -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars aws_s3_bucket_public_access_block.terraform_state ${BUCKET_NAME})
  echo "1 ------------------"
  echo $bucketImportStatus
  bucketPublicAccessBlockImportStatus=$(terraform import -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars aws_s3_bucket_public_access_block.terraform_state ${BUCKET_NAME})
  echo "2 ------------------"

  terraform destroy -auto-approve -lock=true -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars
}

serverlessDeploy() {
  echo "serverlessDeploy - started"
  sls deploy --stage ${TARGET_ENVIRONMENT} --region ${TARGET_REGION}
  echo "serverlessDeploy - completed"
}

serverlessDestroy() {
  echo "serverlessDestroy - started"
  sls remove --stage  ${TARGET_ENVIRONMENT} --region ${TARGET_REGION}
  echo "serverlessDestroy - completed"
}

startLocalstack() {
#  dockerStatus=$(docker-compose up)
  echo "1 -------------"
  echo ${dockerStatus}
  echo "2 -------------"
  localstack start
}

terraformDeployLocal() {
    echo "terraformDeploy - 1"
    export TF_LOG="DEBUG"

    tflocal init

    bucketImportStatus=$(tflocal import -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars aws_s3_bucket_public_access_block.terraform_state ${BUCKET_NAME})
    echo "------------------"
    echo $bucketImportStatus
    bucketPublicAccessBlockImportStatus=$(tflocal import -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars aws_s3_bucket_public_access_block.terraform_state ${BUCKET_NAME})
    echo "------------------"
    echo $bucketPublicAccessBlockImportStatus

    if [[ -n $bucketImportStatus || -n $bucketPublicAccessBlockImportStatus ]]; then
      echo "The terraform S3 backend could not be imported, so one will now be created."

      terraformPlanOutputFile="$(pwd)/out.plan"
      echo "%%%%%%%%%%%%%%%%%%%%%"
      echo ${terraformPlanOutputFile}
      echo "1 ------------------"
      tflocal plan -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars -out="${terraformPlanOutputFile}"
      echo "2 ------------------"
      tflocal apply -auto-approve -lock=true "${terraformPlanOutputFile}"
    else
      echo "An existing remote backend has been detected successfully."
      echo "Re-initializing using the detected remote backend."
    fi
}

serverlessDeployLocal() {
  echo "serverlessDeployLocal - started"
  sls deploy --stage local --region ${TARGET_REGION}
  echo "serverlessDeployLocal - completed"
}

if [ "$#" -ne 1 ]; then
    echo "Improper Arguments passed"
    usage
fi

#FQDN=$2
#DOMAIN=$(echo $FQDN | gcut -d '.' -f 1 --complement)
#REG_PRI="us-east-1"
#REG_SEC="us-west-2"

if [ "$1" = "deploy" ]; then
    echo "deployment started"
    terraformDeploy
    serverlessDeploy
    echo "deployment completed"
elif [ "$1" = "destroy" ]; then
    echo "destruction started"
    serverlessDestroy
    terraformDestroy
    echo "destruction completed"
elif [ "$1" = "test" ]; then
    echo "test started"
    startLocalstack
    terraformDeployLocal
    serverlessDeployLocal
    echo "test completed"
else
    echo "Incorrect arguments passed"
    usage
fi

exit

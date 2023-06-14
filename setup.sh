#!/usr/local/bin/bash

echo "hello"

BASE_NAME="chaos-testing-example"
TARGET_REGION="us-west-2"
TARGET_ENVIRONMENT="sbx"
BUCKET_NAME="sbx-chaos-testing-example-state-us-west-2"

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

terraformDeploy
# terraformDestroy

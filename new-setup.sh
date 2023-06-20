#!/usr/local/bin/bash

BASE_NAME="chaos-testing-example"
TARGET_REGION="us-west-2"
TARGET_ENVIRONMENT="sbx"
BUCKET_NAME="sbx-chaos-testing-example-state-us-west-2"

LOCALSTACK_HOSTNAME="localhost"
EDGE_PORT=4566
#LOCALSTACK_HOSTNAME="internal-mock-cluster-ue1-lb-1600049175.us-east-1.elb.amazonaws.com/mock-services-http/localstack"
#EDGE_PORT=80
REST_API_NAME="api-gateway-chaos-example"
LS_DOMAIN_NAME="chaos-example.demo.com"
LS_HOSTED_ZONE_ID=''
LS_CERT_ARN=''

usage() {
    echo "<deploy|destroy|deploylocal|destroylocal|hello>"
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

initLocalstack() {
  echo "1 -------------"
  export LOCALSTACK_HOSTNAME="${LOCALSTACK_HOSTNAME}"
  echo $LOCALSTACK_HOSTNAME
  export EDGE_PORT="${EDGE_PORT}"
  echo $EDGE_PORT
  echo "2 -------------"
}

terraformDeployLocal() {
    echo "terraformDeployLocal - 1"
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

terraformDestroyLocal() {
  echo "terraformDestroyLocal - started"
  tflocal init
  bucketImportStatus=$(tflocal import -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars aws_s3_bucket_public_access_block.terraform_state ${BUCKET_NAME})
  echo "1 ------------------"
  echo $bucketImportStatus
  bucketPublicAccessBlockImportStatus=$(tflocal import -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars aws_s3_bucket_public_access_block.terraform_state ${BUCKET_NAME})
  echo "2 ------------------"
  tflocal destroy -auto-approve -lock=true -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/${TARGET_REGION}/${TARGET_ENVIRONMENT}.tfvars
  echo "terraformDestroyLocal - ended"
}

createLocalHostedZone() {
  echo "Route53: Creating domain: $LS_DOMAIN_NAME"
  rspDomainName=$(awslocal route53 create-hosted-zone --name $LS_DOMAIN_NAME --caller-reference r53-hz-$LS_DOMAIN_NAME --hosted-zone-config Comment="project:$LS_DOMAIN_NAME" --output json)
  echo "response while creating custom domain: $rspDomainName"
  LS_HOSTED_ZONE_ID=$(echo $rspDomainName | jq .HostedZone.Id | sed -r 's/"\/hostedzone\/(.*)"/\1/g')
  echo "hosted zone id is $LS_HOSTED_ZONE_ID"
  node ./converter.js $LS_HOSTED_ZONE_ID
}

createLocalCertificate() {
  echo "ACM: Creating Certificate"
  rspAcm=$(awslocal acm request-certificate --region $TARGET_REGION --domain-name $LS_DOMAIN_NAME --validation-method DNS --subject-alternative-names *.$LS_DOMAIN_NAME --tags Key=project,Value=$LS_DOMAIN_NAME --output json)
  LS_CERT_ARN=$(echo $rspAcm | jq -r .CertificateArn)
  echo "Cert ARN is $LS_CERT_ARN"
}

createLocalCustomDomain() {
  echo "API Gateway: Creating Custom Domain"
  rspApiGty=$(awslocal apigateway create-domain-name --region $TARGET_REGION --domain-name $LS_DOMAIN_NAME --regional-certificate-arn $LS_CERT_ARN --endpoint-configuration types=REGIONAL)
  echo "Response form Api Gateway is $rspApiGty"
}

serverlessDeployLocal() {
  echo "serverlessDeployLocal - started"
  sls deploy --stage local --region ${TARGET_REGION}
  echo "serverlessDeployLocal - completed"
}

serverlessDestroyLocal() {
  echo "serverlessDestroyLocal - started"
  sls remove --stage  local --region ${TARGET_REGION}
  echo "serverlessDestroyLocal - completed"
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
elif [ "$1" = "deploylocal" ]; then
    echo "local deploy started"
    initLocalstack
    createLocalHostedZone
    createLocalCertificate
    terraformDeployLocal
#    createLocalCustomDomain
    serverlessDeployLocal
    echo "local deploy completed"
elif [ "$1" = "destroylocal" ]; then
    echo "local destroy started"
    initLocalstack
    serverlessDestroyLocal
    terraformDestroyLocal
    echo "local destroy completed"
elif [ "$1" = "hello" ]; then
    node ./converter.js hello
else
    echo "Incorrect arguments passed"
    usage
fi

exit


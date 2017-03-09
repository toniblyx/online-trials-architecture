#!/bin/bash

# This script will create a copy of the online trial architecture, testing
# that the template can be created from scratch.
# Bamboo variables needed are:
# Aws Access access key ${bamboo.aws_access_key_id}
# Secret access key ${bamboo.secret_access_password}
# Stack name ${bamboo.stackName}-${bamboo.planRepository.branchName}-${bamboo.buildNumber}

usage() {
  echo "Usage: createStack.sh <access_key_id> <secret_access_key> <stack_name>"
  exit 1
}

if [ $# -lt 3 ]; then
  usage
else
  source ./common.func
  TEMPLATE_NAME="online-trial-control.yaml"
  S3_TEMPLATE_NAME="$3.yaml"
  STACK_NAME=$(echo -n $3 | tr / - | awk '{print tolower($0)}')
  CAPABILITIES=CAPABILITY_IAM
  STACK_CREATION_TIMEOUT=600

  # Essential Variables
  export AWS_ACCESS_KEY_ID=$1
  export AWS_SECRET_ACCESS_KEY=$2

  # Some logging
  printVarSummary

  # Copy the template to S3
  separator
  logInfo "Copy Cloudformation Template $TEMPLATE_NAME to S3 Bucket s3://$S3_BUCKET/"
  aws s3 mb s3://$S3_BUCKET
  aws s3 cp $TEMPLATE_NAME s3://$S3_BUCKET/$S3_TEMPLATE_NAME

  # Validate the template
  separator
  logInfo "Validate the Cloudformation template"
  aws cloudformation validate-template --template-url https://s3.amazonaws.com/$S3_BUCKET/$S3_TEMPLATE_NAME

  # Create the stack
  separator
  aws cloudformation create-stack --stack-name $STACK_NAME --template-url https://s3.amazonaws.com/$S3_BUCKET/$S3_TEMPLATE_NAME --capabilities $CAPABILITIES --disable-rollback
  if [ $? -ne 0 ]; then
    logError "Stack creation failed."
  fi

  # Wait for the stack to create OK/FAIL
  separator
  logInfo "Waiting for stack creation - $STACK_NAME"

  CREATION_COMPLETE_EVENT="FALSE"
  LOOP_COUNTER=0
  while [ "$CREATION_COMPLETE_EVENT" != "CREATE_COMPLETE" ]
  do
      if [ $LOOP_COUNTER -eq $STACK_CREATION_TIMEOUT ]; then
          TIMEOUT_IN_MIN=`expr $STACK_CREATION_TIMEOUT / 6`
          logError "Stack creation timeout after $TIMEOUT_IN_MIN minutes"
      fi
      STATUS=`aws cloudformation describe-stack-events --stack-name $STACK_NAME | head -n 10 | grep -B1 AWS::CloudFormation::Stack`
      monitorStatus "$STATUS"
      sleep 10
      LOOP_COUNTER=`expr $LOOP_COUNTER + 1`
  done
fi
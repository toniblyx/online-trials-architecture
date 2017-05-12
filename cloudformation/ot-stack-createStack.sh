#!/bin/bash
# This script will create a copy of the online trial architecture, testing
# that the template can be created from scratch.

source common.func

usage() {
  echo "Usage: ot-stack-createStack.sh <access_key_id> <secret_access_key> <stack_name> <ami_id> <user_name> <user_password>"
  exit 1
}

if [ $# -lt 6 ]; then
  usage
else
  TEMPLATE_NAME="online-trial-stack.yaml"
  S3_TEMPLATE_NAME="$3.yaml"
  S3_BUCKET='cfn-templates-alfresco-onlinetrials'
  STACK_NAME=$(echo -n $3 | tr / - | awk '{print tolower($0)}')
  AMI_ID=$4

  CAPABILITIES=CAPABILITY_IAM
  STACK_CREATION_TIMEOUT=600

  # Essential Variables
  export AWS_ACCESS_KEY_ID=$1
  export AWS_SECRET_ACCESS_KEY=$2

  # Some logging
  printVarSummary

  USER_NAME=$5
  USER_PWD=$6

  # Copy the template to S3
  separator
  logInfo "Copy Cloudformation Template $TEMPLATE_NAME to S3 Bucket s3://$S3_BUCKET/"
  aws s3 cp $TEMPLATE_NAME s3://$S3_BUCKET/$S3_TEMPLATE_NAME

  # Replace placeholders
  separator
  logInfo "Replacing placeholders in ot-stack-parameters.json"
  sed -i'.bak' "
      s/@@USERNAME@@/$USER_NAME/g;
      s/@@PASSWORD@@/$USER_PWD/g;
      s/@@AMI_ID@@/$4/g
  " ot-stack-parameters.json

  # Validate the template
  separator
  logInfo "Validate the Cloudformation template"
  aws cloudformation validate-template --template-url https://s3.amazonaws.com/$S3_BUCKET/$S3_TEMPLATE_NAME

  # Create the stack
  separator
  aws cloudformation create-stack --stack-name $STACK_NAME --template-url https://s3.amazonaws.com/$S3_BUCKET/$S3_TEMPLATE_NAME --parameters file://ot-stack-parameters.json --capabilities $CAPABILITIES --disable-rollback
  if [ $? -ne 0 ]; then
    logError "Stack creation failed."
  fi

  # Wait for the stack to create OK/FAIL
  separator
  logInfo "Waiting for stack creation - $STACK_NAME"
  LOOP_COUNTER=0
  while true;
  do
      if [ $LOOP_COUNTER -eq $STACK_CREATION_TIMEOUT ]; then
          TIMEOUT_IN_MIN=`expr $STACK_CREATION_TIMEOUT / 6`
          logError "Stack creation timeout after $TIMEOUT_IN_MIN minutes"
      fi
      STATUS=$(aws cloudformation describe-stacks \
      --stack-name $STACK_NAME \
      --query "Stacks[*].StackStatus" \
      --output text)

      if [[ "$STATUS" == "CREATE_COMPLETE" ]]; then
        separator
        logInfo "Stack successfully created"
        exit 0
      else
        monitorStatus "$STATUS"
        sleep 10
        LOOP_COUNTER=`expr $LOOP_COUNTER + 1`
      fi
  done
fi

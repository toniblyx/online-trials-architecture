#!/bin/bash
# This script will create a copy of the online trial architecture, testing
# that the template can be created from scratch.

usage() {
  echo "Usage: createStack.sh <access_key_id> <secret_access_key> <stack_name> <uname>"
  exit 1
}

if [ $# -lt 7 ]; then
  usage
else
  BAMBOO_WORKING_DIR=$4
  source $BAMBOO_WORKING_DIR/common.func
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
        logInfo "Stack successfully created"
        separator
        URL=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --query "Stacks[*].Outputs[?OutputKey == 'OnlineTrialsTestEndPoint'].OutputValue" \
        --output text)
        echo "url=$URL" > apiurl.properties
        exit 0
      else
        monitorStatus "$STATUS"
        sleep 10
        LOOP_COUNTER=`expr $LOOP_COUNTER + 1`
      fi      
  done
fi

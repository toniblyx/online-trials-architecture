#!/bin/bash

STACK_UPDATE_TIMEOUT=400
CAPABILITIES=CAPABILITY_IAM

usage() {
  echo "Usage: updateStack.sh <access_key_id> <secret_access_key> <stack_name>"
  exit 1
}

source ./common.func
# Essential Variables
export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
STACK_NAME="online-trial-control-test"

# We need to create a change set for the current stack, describe the change set and check the response for the "STATUS"
# if the status was "FAILED" this was because there we no changes to execute, so we delete the change set then exit early
# otherwise we execute the change set
S3_TEMPLATE_NAME="$3.yaml"
aws cloudformation create-change-set --stack-name $STACK_NAME --template-url https://s3.amazonaws.com/$S3_BUCKET/$S3_TEMPLATE_NAME --change-set-name trial-update --capabilities $CAPABILITIES
# give the changeset time to be created
separator
logInfo "Waiting for the change set to be created...."
sleep 30
RESULT=$(aws cloudformation describe-change-set --stack-name $STACK_NAME --change-set-name trial-update --query "Status" --output text)
if [ "$RESULT" == "FAILED" ]; then
  separator
  logInfo "No updates to execute on $STACK_NAME. Exiting"
  aws cloudformation delete-change-set --stack-name $STACK_NAME --change-set-name trial-update
  exit 0
fi

separator
logInfo "Updating stack $STACK_NAME"
aws cloudformation execute-change-set --change-set-name trial-update --stack-name $STACK_NAME
if [ $? -ne 0 ]; then
  logError "Stack update failed."
fi

separator
logInfo "Waiting for stack update $STACK_NAME"
UPDATE_COMPLETE_EVENT="FALSE"
LOOP_COUNTER=0
while [ "$UPDATE_COMPLETE_EVENT" != "UPDATE_COMPLETE" ]
do
    if [ $LOOP_COUNTER -eq $STACK_UPDATE_TIMEOUT ]; then
        TIMEOUT_IN_MIN=`expr $STACK_UPDATE_TIMEOUT / 6`
        logError "Stack update timeout after $TIMEOUT_IN_MIN minutes"
    fi

    STATUS=`aws cloudformation describe-stack-events --stack-name $STACK_NAME | head -n 10 | grep -B1 AWS::CloudFormation::Stack`
    monitorStatus "$STATUS"
    sleep 10
    LOOP_COUNTER=`expr $LOOP_COUNTER + 1`
done
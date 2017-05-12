#!/bin/bash

source common.func

usage() {
    echo "Usage: deleteStack.sh <aws_access_key> <secret_key> <stackName>"
    exit 1
}

if [ $# -lt 3 ]; then
    usage
else
    STACK_DELETION_TIMEOUT=300
    STACK_NAME=$(echo -n $3| tr / - | awk '{print tolower($0)}')
    printVarSummary

    # Essential Variables
    export AWS_ACCESS_KEY_ID=$1
    export AWS_SECRET_ACCESS_KEY=$2

    separator
    logInfo "Deleting the stack $STACK_NAME"

    aws cloudformation delete-stack --stack-name $STACK_NAME
    if [ $? -ne 0 ]; then
        logError "Stack deletion failed."
    fi

    separator
    logInfo "Waiting for stack deletion to complete"

    DELETE_COMPLETE_EVENT="FALSE"
    LOOP_COUNTER=0
    while [ "$DELETE_COMPLETE_EVENT" != "DELETE_COMPLETE" ]
    do
        if [ $LOOP_COUNTER -eq $STACK_DELETION_TIMEOUT ]; then
            TIMEOUT_IN_MIN=`expr $STACK_DELETION_TIMEOUT / 6`
            logError "Stack deletion timeout after $TIMEOUT_IN_MIN minutes"
        fi

        STATUS=$(aws cloudformation describe-stack-events \
        --stack-name $STACK_NAME \
        --query "StackEvents[?ResourceType == 'AWS::CloudFormation::Stack'].ResourceStatus" \
        --output text | head -n1)

        if [[ "$STATUS" != "" ]]; then
            monitorStatus $STATUS
        else
            logInfo "Stack successfully deleted"
            separator
            exit 0
        fi
        sleep 10
        LOOP_COUNTER=`expr $LOOP_COUNTER + 1`
    done
fi

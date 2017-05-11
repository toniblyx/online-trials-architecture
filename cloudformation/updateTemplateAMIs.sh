#!/bin/bash

source common.func

AMI_IDS_FILE="ami_ids.properties"

usage() {
    echo "Usage: updateTemplateAMIs.sh <packer-build.log> <region>"
    exit 1
}

if [ $# -ne 2 ]; then
    usage
fi

if [ ! -f $1 ]; then
    logError "$1 file does not exist"
fi

SRC_FILE=$1
AWS_REGION=$2

separator
echo "Source file: $SRC_FILE"
echo "Region: $AWS_REGION"
separator

logInfo "Parsing: $SRC_FILE"

ALFRESCO_AMI=`grep "$AWS_REGION: " $SRC_FILE | sed 's/^.*ami-/ami-/' | cut -c 1-12`

logInfo "Found Alfresco AMI: $ALFRESCO_AMI"
echo "alfrescoAMI=$ALFRESCO_AMI" >> $AMI_IDS_FILE

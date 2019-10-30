#!/usr/bin/env bash
set +x



export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account -r)
echo "Your AWS account id is: ${AWS_ACCOUNT_ID}"

if [ $# -eq 0 ]
  then
    DATALAKE=pkcdp
    DATALAKE_BUCKET=pk-cdp
  else
    DATALAKE="$1"
    DATALAKE_BUCKET="$2"
fi

#export DATALAKE=pkcdp
#export DATALAKE_BUCKET=pk-cdp
export DATALAKE_PATH=${DATALAKE_BUCKET}/user/purnimak/dls/${DATALAKE}
export REGION=us-west-2
export PUBLIC_KEY=pk-uswest2
export CREDENTIAL_NAME=pk-aws-role


export CDP_PROFILE=prod
export DP_PROFILE=prod
export CDP_IAM=
export CDP_CORE=
export INTERNET_OPTION=public


#------------------------------------------------------- DO NOT CHANGE FOLLOWING ------------------------------------------#
# Four Roles
export IDBROKER_ROLE=${DATALAKE}-idbroker-role
export DATALAKE_LOG_ROLE=${DATALAKE}-log-role
export DATALAKE_ADMIN_ROLE=${DATALAKE}-datalake-admin-role
export DATALAKE_RANGER_AUDIT_ROLE=${DATALAKE}-ranger-audit-role

# Six Policies
export IDBROKER_ROLE_POLICY=${DATALAKE}-idbroker-role-policy
export LOG_POLICY_S3_ACCESS=${DATALAKE}-log-policy-s3access
export BUCKET_POLICY_S3_ACCESS=${DATALAKE}-bucket-policy-s3access
export DYNAMODB_POLICY_NAME=${DATALAKE}-dynamodb-policy
export RANGER_POLICY_NAME=${DATALAKE}-ranger-audit-policy-s3access
export DATALAKE_POLICY_NAME=${DATALAKE}-data-lake-policy-s3access


export S3GUARD_TABLE=cdp-${DATALAKE}

export DATALAKE_COMMON_POLICY=${DATALAKE}-common
export DATALAKE_S3GUARD_POLICY=${DATALAKE}-s3guard
export CDP_ADMIN_GROUP=cdp_${DATALAKE}



export DATALAKE_DATAENG_ROLE=dataeng-${DATALAKE}
export DATALAKE_DATASCI_ROLE=datasci-${DATALAKE}

##########################
###### Input Section ######

#------------------------------------ AWS Inputs ---------------------------------#
export DATALAKE_PATH=${DATALAKE_BUCKET}/${DATALAKE}




#export DATALAKE_COMMON_POLICY=${DATALAKE}-common
#export CDP_ADMIN_GROUP=cdp_${DATALAKE}
#export DATALAKE_DATAENG_ROLE=dataeng-${DATALAKE}
#export DATALAKE_DATASCI_ROLE=datasci-${DATALAKE}
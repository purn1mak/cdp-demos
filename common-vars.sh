#!/usr/bin/env bash
set +x



export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account -r)
echo "Your AWS account id is: ${AWS_ACCOUNT_ID}"


export DATALAKE=pkcdp
export DATALAKE_BUCKET=pk-cdp
export DATALAKE_PATH=${DATALAKE_BUCKET}/user/purnimak/dls/${DATALAKE}
export REGION=us-west-2
export PUBLIC_KEY=pk-uswest2
export CREDENTIAL_NAME=pk-aws-role


export CDP_PROFILE=prod
export DP_PROFILE=prod
export CDP_IAM=
export CDP_CORE=
export INTERNET_OPTION=public

export IDBROKER_ROLE=idbroker-${DATALAKE}
export DATALAKE_ADMIN_ROLE=dladmin-${DATALAKE}
export DATALAKE_DATAENG_ROLE=dataeng-${DATALAKE}
export DATALAKE_DATASCI_ROLE=datasci-${DATALAKE}
export DATALAKE_LOG_ROLE=log-${DATALAKE}
export S3GUARD_TABLE=cdp-${DATALAKE}
export DATALAKE_COMMON_POLICY=${DATALAKE}-common
export DATALAKE_S3GUARD_POLICY=${DATALAKE}-s3guard
export CDP_ADMIN_GROUP=cdp_${DATALAKE}

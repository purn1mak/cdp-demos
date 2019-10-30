#!/usr/bin/env bash

###### Input Section ######
#---------------------------------------------------------------------------#
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account -r)
echo "Your AWS account id is: ${AWS_ACCOUNT_ID}"

#------------------------------------ AWS Inputs ---------------------------------#
export DATALAKE=pk-dl-01
export DATALAKE_BUCKET=pk-cdp
export REGION=us-west-2
#export PUBLIC_KEY=

#------------------------------------ CDP Inputs ---------------------------------#
#export CREDENTIAL_NAME=pk-aws-cred

##---------------------------------------------- No Inputs after this line -----------------------------------------##
##----------------------------------------------- DO NOT CHANGE FOLLOWING ------------------------------------------##

#Derived  For AWS
export S3GUARD_TABLE=${DATALAKE}-s3guard
export DATALAKE_PATH=${DATALAKE_BUCKET}/${DATALAKE}

#Derived  For CDP
#export CDP_PROFILE=prod
#export DP_PROFILE=prod
#export CDP_IAM=
#export CDP_CORE=
#export INTERNET_OPTION=public

# Six Roles
export IDBROKER_ROLE=${DATALAKE}-idbroker-role
export DATALAKE_LOG_ROLE=${DATALAKE}-log-role
export DATALAKE_ADMIN_ROLE=${DATALAKE}-datalake-admin-role
export DATALAKE_RANGER_AUDIT_ROLE=${DATALAKE}-ranger-audit-role
export DATALAKE_DATAENG_ROLE=${DATALAKE}-dataeng
export DATALAKE_DATASCI_ROLE=${DATALAKE}-datasci

# Policies
export IDBROKER_ROLE_POLICY=${DATALAKE}-idbroker-role-policy
export LOG_POLICY_S3_ACCESS=${DATALAKE}-log-policy-s3access
export BUCKET_POLICY_S3_ACCESS=${DATALAKE}-bucket-policy-s3access
export DYNAMODB_POLICY_NAME=${DATALAKE}-dynamodb-policy
export RANGER_POLICY_NAME=${DATALAKE}-ranger-audit-policy-s3access
export DATALAKE_POLICY_NAME=${DATALAKE}-data-lake-policy-s3access

#------------------------------------------- Generating JSONs for Policies ---------------------------------------------#

## TWO TRUST POLICIES
cat << IDBROKERASSUMETRUSTPOLICY > assume-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
IDBROKERASSUMETRUSTPOLICY

cat << IDBROKERTRUSTPOLICY > idbroker-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${IDBROKER_ROLE}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
IDBROKERTRUSTPOLICY

# EIGHT PERMISSION POLICIES
cat << IDBROKERASSUMERPOLICY > idbroker-assume-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "*"
        }
    ]
}
IDBROKERASSUMERPOLICY

cat << S3ACCESSPOLICY > log-policy-s3access.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${DATALAKE_PATH}/logs/*"
        }
    ]
}
S3ACCESSPOLICY

cat << S3ACCESSPOLICY > bucket-policy-s3access.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetAccountPublicAccessBlock",
                "s3:ListAllMyBuckets",
                "s3:ListJobs",
                "s3:CreateJob",
                "s3:HeadBucket"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowListingOfDataLakeFolder",
            "Action": [
                "s3:ListBucketByTags",
                "s3:GetLifecycleConfiguration",
                "s3:GetBucketTagging",
                "s3:GetInventoryConfiguration",
                "s3:GetObjectVersionTagging",
                "s3:ListBucketVersions",
                "s3:GetBucketLogging",
                "s3:ListBucket",
                "s3:GetAccelerateConfiguration",
                "s3:GetBucketPolicy",
                "s3:GetObjectVersionTorrent",
                "s3:GetObjectAcl",
                "s3:GetEncryptionConfiguration",
                "s3:GetBucketRequestPayment",
                "s3:GetObjectVersionAcl",
                "s3:GetObjectTagging",
                "s3:GetMetricsConfiguration",
                "s3:GetBucketPublicAccessBlock",
                "s3:GetBucketPolicyStatus",
                "s3:ListBucketMultipartUploads",
                "s3:GetBucketWebsite",
                "s3:GetBucketVersioning",
                "s3:GetBucketAcl",
                "s3:GetBucketNotification",
                "s3:GetReplicationConfiguration",
                "s3:ListMultipartUploadParts",
                "s3:GetObject",
                "s3:GetObjectTorrent",
                "s3:GetBucketCORS",
                "s3:GetAnalyticsConfiguration",
                "s3:GetObjectVersionForReplication",
                "s3:GetBucketLocation",
                "s3:GetObjectVersion"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${DATALAKE_BUCKET}",
                "arn:aws:s3:::${DATALAKE_BUCKET}/*"
            ]
        }
    ]
}
S3ACCESSPOLICY

cat << DYNAMOACCESSPOLICY > dynamodb-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:List*",
                "dynamodb:DescribeReservedCapacity*",
                "dynamodb:DescribeLimits",
                "dynamodb:DescribeTimeToLive"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:DeleteItem",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:Query",
                "dynamodb:UpdateItem",
                "dynamodb:CreateTable",
                "dynamodb:DeleteTable",
                "dynamodb:Scan",
                "dynamodb:TagResource",
                "dynamodb:UntagResource",
                "dynamodb:UpdateTable"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/${S3GUARD_TABLE}"
        }
    ]
}
DYNAMOACCESSPOLICY

cat << RANGERPOLICY > ranger-audit-policy-s3-access.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "FullObjectAccessUnderAuditDir",
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:Put*"
            ],
            "Resource": "arn:aws:s3:::${DATALAKE_PATH}/ranger/audit/*"
        },
        {
            "Sid": "LimitedAccessToDataLakeBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:AbortMultipartUpload"
            ],
            "Resource": "arn:aws:s3:::${DATALAKE_BUCKET}"
        }
    ]
}
RANGERPOLICY

cat << DATALAKEPOLICY > data-lake-admin-policy-s3-access.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${DATALAKE_PATH}",
                "arn:aws:s3:::${DATALAKE_PATH}/*"
            ]
        }
    ]
}
DATALAKEPOLICY

cat << DATAENGPOLICY > dataeng-policy-s3access.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${DATALAKE_PATH}/data/*"
        }
    ]
}
DATAENGPOLICY

cat << DATASCIPOLICY > datasci-policy-s3access.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${DATALAKE_PATH}/data/processed/*"
        }
    ]
}
DATASCIPOLICY

#------------------------- Policy & Role Creation Starts Here ---------------------------#

#------------------------------------------- Creating Policies & IDBROKER ROLE ---------------------------------------------#

aws iam create-policy --policy-name  ${IDBROKER_ROLE_POLICY} --policy-document file://idbroker-assume-policy.json
aws iam create-policy --policy-name  ${LOG_POLICY_S3_ACCESS} --policy-document file://log-policy-s3access.json
aws iam create-policy --policy-name  ${BUCKET_POLICY_S3_ACCESS} --policy-document file://bucket-policy-s3access.json
aws iam create-policy --policy-name  ${DYNAMODB_POLICY_NAME} --policy-document file://dynamodb-policy.json
aws iam create-policy --policy-name  ${RANGER_POLICY_NAME} --policy-document file://ranger-audit-policy-s3-access.json
aws iam create-policy --policy-name  ${DATALAKE_POLICY_NAME} --policy-document file://data-lake-admin-policy-s3-access.json
aws iam create-policy --policy-name  ${DATALAKE_DATAENG_ROLE} --policy-document file://dataeng-policy-s3access.json
aws iam create-policy --policy-name  ${DATALAKE_DATASCI_ROLE} --policy-document file://datasci-policy-s3access.json

#------------------------------------------- Creating Roles ---------------------------------------------#
#ID BROKER ROLE WITH INSTANCE PROFILE
aws iam create-role --role-name ${IDBROKER_ROLE} --assume-role-policy-document file://assume-trust-policy.json
aws iam create-instance-profile --instance-profile-name ${IDBROKER_ROLE}
aws iam add-role-to-instance-profile --instance-profile-name ${IDBROKER_ROLE} --role-name ${IDBROKER_ROLE}

#DATALAKE LOG ROLE WITH INSTANCE PROFILE
aws iam create-role --role-name ${DATALAKE_LOG_ROLE} --assume-role-policy-document file://assume-trust-policy.json
aws iam create-instance-profile --instance-profile-name ${DATALAKE_LOG_ROLE}
aws iam add-role-to-instance-profile --instance-profile-name ${DATALAKE_LOG_ROLE} --role-name ${DATALAKE_LOG_ROLE}

#DATALAKE ADMIN ROLE WITHOUT INSTANCE PROFILE
aws iam create-role --role-name ${DATALAKE_ADMIN_ROLE} --assume-role-policy-document file://idbroker-trust-policy.json
aws iam create-instance-profile --instance-profile-name ${DATALAKE_ADMIN_ROLE}
aws iam add-role-to-instance-profile --instance-profile-name ${DATALAKE_ADMIN_ROLE} --role-name ${DATALAKE_ADMIN_ROLE}

#RANGER AUDIT ROLE WITHOUT INSTANCE PROFILE
aws iam create-role --role-name ${DATALAKE_RANGER_AUDIT_ROLE} --assume-role-policy-document file://idbroker-trust-policy.json
aws iam create-instance-profile --instance-profile-name ${DATALAKE_RANGER_AUDIT_ROLE}
aws iam add-role-to-instance-profile --instance-profile-name ${DATALAKE_RANGER_AUDIT_ROLE} --role-name ${DATALAKE_RANGER_AUDIT_ROLE}

#DATA ENGINEERING ROLE WITHOUT INSTANCE PROFILE
aws iam create-role --role-name ${DATALAKE_DATAENG_ROLE} --assume-role-policy-document file://idbroker-trust-policy.json
aws iam create-instance-profile --instance-profile-name ${DATALAKE_DATAENG_ROLE}
aws iam add-role-to-instance-profile --instance-profile-name ${DATALAKE_DATAENG_ROLE} --role-name ${DATALAKE_DATAENG_ROLE}

#DATA SCIENCE ROLE WITHOUT INSTANCE PROFILE
aws iam create-role --role-name ${DATALAKE_DATASCI_ROLE} --assume-role-policy-document file://idbroker-trust-policy.json
aws iam create-instance-profile --instance-profile-name ${DATALAKE_DATASCI_ROLE}
aws iam add-role-to-instance-profile --instance-profile-name ${DATALAKE_DATASCI_ROLE} --role-name ${DATALAKE_DATASCI_ROLE}

#------------- Waiting For Last Role To Be Created ------------#

aws iam wait role-exists --role-name ${IDBROKER_ROLE}
aws iam wait role-exists --role-name ${DATALAKE_LOG_ROLE}
aws iam wait role-exists --role-name ${DATALAKE_ADMIN_ROLE}
aws iam wait role-exists --role-name ${DATALAKE_RANGER_AUDIT_ROLE}
aws iam wait role-exists --role-name ${DATALAKE_DATAENG_ROLE}
aws iam wait role-exists --role-name ${DATALAKE_DATASCI_ROLE}

#------------------------------------------- Assigning Policies To Roles ---------------------------------------------#

# ID BROKER ROLE POLICY ATTACHMENT
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${IDBROKER_ROLE_POLICY} --role-name ${IDBROKER_ROLE}

# LOG ROLE POLICY ATTACHMENT
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${LOG_POLICY_S3_ACCESS} --role-name ${DATALAKE_LOG_ROLE}
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${BUCKET_POLICY_S3_ACCESS} --role-name ${DATALAKE_LOG_ROLE}

#RANGER ADMIN POLICY ATTACHMENT
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${RANGER_POLICY_NAME} --role-name ${DATALAKE_RANGER_AUDIT_ROLE}
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${BUCKET_POLICY_S3_ACCESS} --role-name ${DATALAKE_RANGER_AUDIT_ROLE}
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DYNAMODB_POLICY_NAME} --role-name ${DATALAKE_RANGER_AUDIT_ROLE}

#DATALAKE ADMIN POLICY ATTACHMENT
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_POLICY_NAME} --role-name ${DATALAKE_ADMIN_ROLE}
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${BUCKET_POLICY_S3_ACCESS} --role-name ${DATALAKE_ADMIN_ROLE}
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DYNAMODB_POLICY_NAME} --role-name ${DATALAKE_ADMIN_ROLE}

#DATAENG POLICY ATTACHMENT
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_DATAENG_ROLE} --role-name ${DATALAKE_DATAENG_ROLE}
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${BUCKET_POLICY_S3_ACCESS} --role-name ${DATALAKE_DATAENG_ROLE}
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DYNAMODB_POLICY_NAME} --role-name ${DATALAKE_DATAENG_ROLE}

#DATA SCIENCE POLICY ATTACHMENT
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_DATASCI_ROLE} --role-name ${DATALAKE_DATASCI_ROLE}
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${BUCKET_POLICY_S3_ACCESS} --role-name ${DATALAKE_DATASCI_ROLE}
aws iam attach-role-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DYNAMODB_POLICY_NAME} --role-name ${DATALAKE_DATASCI_ROLE}

#------------------------------------------- End Of AWS Roles and Policies Creation ---------------------------------------------#

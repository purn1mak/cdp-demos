#!/usr/bin/env bash

. common-vars.sh


cat << TRUSTPOLICY > s3access-role-trust-policy-1.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${AWS_ACCOUNT_ID}:root"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
TRUSTPOLICY

cat << TRUSTPOLICY > s3access-role-trust-policy-2.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${AWS_ACCOUNT_ID}:root"
        ]
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${IDBROKER_ROLE}"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
TRUSTPOLICY

cat << DYNAMOACCESSPOLICY > dynamodb-policy.json
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
                "s3:HeadBucket",
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
                "dynamodb:DescribeLimits",
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

cat << S3ACCESSPOLICY > datalakeadmin-policy-s3access.json
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
S3ACCESSPOLICY

cat << S3ACCESSPOLICY > dataeng-policy-s3access.json
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
S3ACCESSPOLICY

cat << S3ACCESSPOLICY > datasci-policy-s3access.json
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
S3ACCESSPOLICY

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

cat << IDBROKERASSUMERPOLICY > idbroker-assumer-policy.json
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

aws iam create-role --role-name ${IDBROKER_ROLE} --assume-role-policy-document file://idbroker-assumer-trust-policy.json
echo "1 Create role: ${IDBROKER_ROLE}"
aws iam wait role-exists --role-name ${IDBROKER_ROLE}
aws iam create-instance-profile --instance-profile-name ${IDBROKER_ROLE}
aws iam add-role-to-instance-profile --instance-profile-name ${IDBROKER_ROLE} --role-name ${IDBROKER_ROLE}
#Create the common S3 bucket access and DynamoDb table access policies
aws iam create-policy --policy-name ${DATALAKE_COMMON_POLICY} --policy-document file://bucket-policy-s3access.json
aws iam create-policy --policy-name ${DATALAKE_S3GUARD_POLICY} --policy-document file://dynamodb-policy.json


#Create an S3 access role for the datalake admin and attach policies to it

aws iam create-role --role-name ${DATALAKE_ADMIN_ROLE} --assume-role-policy-document file://s3access-role-trust-policy-1.json
echo "2 Create role: ${DATALAKE_ADMIN_ROLE}"
aws iam wait role-exists --role-name ${DATALAKE_ADMIN_ROLE}
aws iam update-assume-role-policy --role-name ${DATALAKE_ADMIN_ROLE} --policy-document file://s3access-role-trust-policy-2.json
aws iam create-policy --policy-name ${DATALAKE_ADMIN_ROLE} --policy-document file://datalakeadmin-policy-s3access.json
aws iam attach-role-policy --role-name ${DATALAKE_ADMIN_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_COMMON_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_ADMIN_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_S3GUARD_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_ADMIN_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_ADMIN_ROLE}
echo "Attaching policies: ${DATALAKE_COMMON_POLICY} , ${DATALAKE_S3GUARD_POLICY} , ${DATALAKE_ADMIN_ROLE} to ${DATALAKE_ADMIN_ROLE}"



# Create an S3 access role for the log role and attach policies to it

aws iam create-role --role-name ${DATALAKE_LOG_ROLE} --assume-role-policy-document file://s3access-role-trust-policy-1.json
echo "3 Create role: ${DATALAKE_LOG_ROLE}"

aws iam create-instance-profile --instance-profile-name ${DATALAKE_LOG_ROLE}

aws iam update-assume-role-policy --role-name ${DATALAKE_LOG_ROLE} --policy-document file://s3access-role-trust-policy-2.json
aws iam create-policy --policy-name ${DATALAKE_LOG_ROLE} --policy-document file://datasci-policy-s3access.json

aws iam attach-role-policy --role-name ${DATALAKE_LOG_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_COMMON_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_LOG_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_S3GUARD_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_LOG_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_LOG_ROLE}
echo "Attaching policies: ${DATALAKE_COMMON_POLICY} , ${DATALAKE_S3GUARD_POLICY} , ${DATALAKE_ADMIN_ROLE} to ${DATALAKE_LOG_ROLE}"

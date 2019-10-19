#!/usr/bin/env bash
# Create a new environment with a datalake



For instructions on how to download and setup cdp cli, start here https://docs.google.com/document/d/1bzO1wwiJ-QdZAURPtK2D4wd0VfX1nCRRNz0rWy3yydY/edit#

Create profiles called dev, stage and prod (note I only have steps for dev and prod right now).

To run this end to end, 
<code>sed -n '/^```/,/^```/ p' < README.md | sed '/^```/ d' > all.sh</code>
Open all.sh, change the names and paths for the core variables below and hack away.

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account -r)
echo "Your AWS account id is: ${AWS_ACCOUNT_ID}"

# If you don't have jq in place, just set it up manually e.g:
# export AWS_ACCOUNT_ID=980678866538

# The core variables that determine where your datalake is and what it is called
export DATALAKE=strata
export DATALAKE_BUCKET=cldr-cdp
export DATALAKE_PATH=${DATALAKE_BUCKET}/user/rvenkatesh/dls/${DATALAKE}
export REGION=us-west-2
export PUBLIC_KEY=rv-aws-new
export CREDENTIAL_NAME=rv-aws-role

# The profile you are running against - dev/int/stage/prod etc
export CDP_PROFILE=dev 
export DP_PROFILE=dev 
export CDP_IAM="--endpoint-url https://iamapi.thunderhead-dev.cloudera.com"
export CDP_CORE="--endpoint-url https://cloudera.dps.mow-dev.cloudera.com"
export INTERNET_OPTION=private

export CDP_PROFILE=stage
export DP_PROFILE=stage
export CDP_IAM="--endpoint-url https://iamapi.thunderhead-stage.cloudera.com"
export CDP_CORE="--endpoint-url https://cloudera.cdp.mow-stage.cloudera.com"
export INTERNET_OPTION=public

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

aws iam wait role-exists --role-name ${IDBROKER_ROLE}

aws iam create-instance-profile --instance-profile-name ${IDBROKER_ROLE}

aws iam add-role-to-instance-profile --instance-profile-name ${IDBROKER_ROLE} --role-name ${IDBROKER_ROLE}
#Create the common S3 bucket access and DynamoDb table access policies
aws iam create-policy --policy-name ${DATALAKE_COMMON_POLICY} --policy-document file://bucket-policy-s3access.json

aws iam create-policy --policy-name ${DATALAKE_S3GUARD_POLICY} --policy-document file://dynamodb-policy.json


#Create an S3 access role for the datalake admin and attach policies to it

aws iam create-role --role-name ${DATALAKE_ADMIN_ROLE} --assume-role-policy-document file://s3access-role-trust-policy-1.json

aws iam wait role-exists --role-name ${DATALAKE_ADMIN_ROLE}

aws iam update-assume-role-policy --role-name ${DATALAKE_ADMIN_ROLE} --policy-document file://s3access-role-trust-policy-2.json

aws iam create-policy --policy-name ${DATALAKE_ADMIN_ROLE} --policy-document file://datalakeadmin-policy-s3access.json

aws iam attach-role-policy --role-name ${DATALAKE_ADMIN_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_COMMON_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_ADMIN_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_S3GUARD_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_ADMIN_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_ADMIN_ROLE}


# Create an S3 access role for the data-engineer and attach policies to it

# The voodoo pattern with the assume role policy document is to workaround an occasional error that the IDBROKER_ROLE could not
# be found even though it is created above
aws iam create-role --role-name ${DATALAKE_DATAENG_ROLE} --assume-role-policy-document file://s3access-role-trust-policy-1.json

aws iam wait role-exists --role-name ${DATALAKE_DATAENG_ROLE}

aws iam update-assume-role-policy --role-name ${DATALAKE_DATAENG_ROLE} --policy-document file://s3access-role-trust-policy-2.json

aws iam create-policy --policy-name ${DATALAKE_DATAENG_ROLE} --policy-document file://dataeng-policy-s3access.json

aws iam attach-role-policy --role-name ${DATALAKE_DATAENG_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_COMMON_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_DATAENG_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_S3GUARD_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_DATAENG_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_DATAENG_ROLE}


# Create an S3 access role for the data-scientists role and attach policies to it

aws iam create-role --role-name ${DATALAKE_DATASCI_ROLE} --assume-role-policy-document file://s3access-role-trust-policy-1.json

aws iam wait role-exists --role-name ${DATALAKE_DATASCI_ROLE}

aws iam update-assume-role-policy --role-name ${DATALAKE_DATASCI_ROLE} --policy-document file://s3access-role-trust-policy-2.json
aws iam create-policy --policy-name ${DATALAKE_DATASCI_ROLE} --policy-document file://datasci-policy-s3access.json

aws iam attach-role-policy --role-name ${DATALAKE_DATASCI_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_COMMON_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_DATASCI_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_S3GUARD_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_DATASCI_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_DATASCI_ROLE}


# Create an S3 access role for the log role and attach policies to it

aws iam create-role --role-name ${DATALAKE_LOG_ROLE} --assume-role-policy-document file://s3access-role-trust-policy-1.json

aws iam create-instance-profile --instance-profile-name ${DATALAKE_LOG_ROLE}

aws iam update-assume-role-policy --role-name ${DATALAKE_LOG_ROLE} --policy-document file://s3access-role-trust-policy-2.json
aws iam create-policy --policy-name ${DATALAKE_LOG_ROLE} --policy-document file://datasci-policy-s3access.json

aws iam attach-role-policy --role-name ${DATALAKE_LOG_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_COMMON_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_LOG_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_S3GUARD_POLICY}
aws iam attach-role-policy --role-name ${DATALAKE_LOG_ROLE} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_LOG_ROLE}


# Finally update the idbroker policy itself - am not sure if it was needed
# aws iam put-role-policy --role-name ${IDBROKER_ROLE} --policy-document file://idbroker-assumer-policy.json --policy-name "idbroker-assumer-policy"

# In case we need to cleanup - not yet tested

aws iam remove-role-from-instance-profile --instance-profile-name ${IDBROKER_ROLE} --role-name ${IDBROKER_ROLE}
aws iam delete-instance-profile --instance-profile-name ${IDBROKER_ROLE}

aws iam remove-role-from-instance-profile --instance-profile-name ${DATALAKE_LOG_ROLE} --role-name ${DATALAKE_LOG_ROLE}
aws iam delete-instance-profile --instance-profile-name ${DATALAKE_LOG_ROLE}

aws iam delete-role --role-name ${IDBROKER_ROLE}

aws iam detach-role-policy --role-name ${DATALAKE_ADMIN_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_COMMON_POLICY}"
aws iam detach-role-policy --role-name ${DATALAKE_ADMIN_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_S3GUARD_POLICY}"
aws iam detach-role-policy --role-name ${DATALAKE_ADMIN_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_ADMIN_ROLE}"
aws iam delete-role --role-name ${DATALAKE_ADMIN_ROLE}

aws iam detach-role-policy --role-name ${DATALAKE_DATAENG_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_COMMON_POLICY}"
aws iam detach-role-policy --role-name ${DATALAKE_DATAENG_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_S3GUARD_POLICY}"
aws iam detach-role-policy --role-name ${DATALAKE_DATAENG_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_DATAENG_ROLE}"
aws iam delete-role --role-name ${DATALAKE_DATAENG_ROLE}

aws iam detach-role-policy --role-name ${DATALAKE_DATASCI_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_COMMON_POLICY}"
aws iam detach-role-policy --role-name ${DATALAKE_DATASCI_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_S3GUARD_POLICY}"
aws iam detach-role-policy --role-name ${DATALAKE_DATASCI_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_DATASCI_ROLE}"
aws iam delete-role --role-name ${DATALAKE_DATASCI_ROLE}

aws iam detach-role-policy --role-name ${DATALAKE_LOG_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_COMMON_POLICY}"
aws iam detach-role-policy --role-name ${DATALAKE_LOG_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_S3GUARD_POLICY}"
aws iam detach-role-policy --role-name ${DATALAKE_LOG_ROLE} --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_LOG_ROLE}"
aws iam delete-role --role-name ${DATALAKE_LOG_ROLE}

aws iam delete-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_DATAENG_ROLE}"
aws iam delete-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_DATASCI_ROLE}"
aws iam delete-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_LOG_ROLE}"

aws iam delete-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_COMMON_POLICY}"
aws iam delete-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_S3GUARD_POLICY}"
aws iam delete-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${DATALAKE_ADMIN_ROLE}"

# Create the CDP artifacts for an environment

cdp iam create-group --group-name ${CDP_ADMIN_GROUP} --profile ${CDP_PROFILE} ${CDP_IAM}

cdp iam update-group --group-name ${CDP_ADMIN_GROUP} --no-sync-membership-on-user-login ${CDP_IAM}

export CDP_ADMIN_GROUP_CRN=`cdp iam list-groups --group-names ${CDP_ADMIN_GROUP} --profile ${CDP_PROFILE} ${CDP_IAM} | jq '.groups[0].crn'`

export DATAENG_GROUP_CRN=`cdp iam list-groups --group-names data_eng --profile ${CDP_PROFILE} ${CDP_IAM} | jq '.groups[0].crn'`

export DATASCI_GROUP_CRN=`cdp iam list-groups --group-names data_sci --profile ${CDP_PROFILE} ${CDP_IAM} | jq '.groups[0].crn'`

cat << DPCLIENVDEFN > dp-cli-env-private.json
{
  "name": "${DATALAKE}",
  "description": "Created by cdp-demo README",
  "location": {
    "name": "${REGION}"
  },
  "authentication": {
    "publicKeyId": "${PUBLIC_KEY}"
  },
  "credentialName": "${CREDENTIAL_NAME}",
  "telemetry": {
    "logging": {
      "s3": {
        "instanceProfile": "arn:aws:iam::${AWS_ACCOUNT_ID}:instance-profile/${DATALAKE_LOG_ROLE}"
      },
      "storageLocation": "s3a://${DATALAKE_PATH}/logs"
    }
  },
  "regions": [
    "${REGION}"
  ],
  "securityAccess": {
    "defaultSecurityGroupId": "sg-0b54bcafda0b44b28",
    "securityGroupIdForKnox": "sg-0b54bcafda0b44b28"
  },
  "aws": {
    "s3guard": {
      "dynamoDbTableName": "${S3GUARD_TABLE}"
    }
  },
  "idBrokerMappingSource": "IDBMMS",
  "network": {
    "subnetIds": [
      "subnet-02d25e06bb8bcce9e",
      "subnet-0727c0067a06c31f7",
      "subnet-08435fb0a78dd9080"
    ],
    "aws": {
      "vpcId": "vpc-071202b5656f08a83"
    }
  }
}
DPCLIENVDEFN

cat << DPCLIENVDEFN > dp-cli-env-public.json
{
  "name": "${DATALAKE}",
  "description": "Created by cdp-demo README",
  "location": {
    "name": "${REGION}"
  },
  "authentication": {
    "publicKeyId": "${PUBLIC_KEY}"
  },
  "credentialName": "${CREDENTIAL_NAME}",
  "telemetry": {
    "logging": {
      "s3": {
        "instanceProfile": "arn:aws:iam::${AWS_ACCOUNT_ID}:instance-profile/${DATALAKE_LOG_ROLE}"
      },
      "storageLocation": "s3a://${DATALAKE_PATH}/logs"
    }
  },
  "regions": [
    "${REGION}"
  ],
  "securityAccess": {
    "cidr": "0.0.0.0/0"
  },
  "aws": {
    "s3guard": {
      "dynamoDbTableName": "${S3GUARD_TABLE}"
    }
  },
  "idBrokerMappingSource": "IDBMMS",
  "network": {
    "networkCidr": "10.10.0.0/16"
  }
}
DPCLIENVDEFN


cat << MAPPINGS > mappings.json
{
    "environmentName": "${DATALAKE}",
    "dataAccessRole": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${DATALAKE_ADMIN_ROLE}",
    "baselineRole": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${DATALAKE_LOG_ROLE}",
    "mappings": [
        {
            "accessorCrn": ${CDP_ADMIN_GROUP_CRN},
            "role": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${DATALAKE_ADMIN_ROLE}"
        },
        {
            "accessorCrn": ${DATAENG_GROUP_CRN},
            "role": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${DATALAKE_DATAENG_ROLE}"
        },
        {
            "accessorCrn": ${DATASCI_GROUP_CRN},
            "role": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${DATALAKE_DATASCI_ROLE}"
        }
    ],
    "setEmptyMappings": false
}
MAPPINGS

cat << DLJSON > dldefn.json
{
    "datalakeName": "${DATALAKE}",
    "environmentName": "${DATALAKE}",
    "cloudProviderConfiguration": {
        "instanceProfile": "arn:aws:iam::${AWS_ACCOUNT_ID}:instance-profile/${IDBROKER_ROLE}",
        "storageBucketLocation": "s3a://${DATALAKE_PATH}"
    },
    "tags": [
        {
            "key": "real-creator",
            "value": "rvenkatesh@cloudera.com"
        }
    ]
}
DLJSON

# cdp environments create-aws-environment --cli-input-json env.json --environment-name ${DATALAKE} --profile ${CDP_PROFILE}

# For now, create the env using the DP CLI
dp env create from-file --file dp-cli-env-${INTERNET_OPTION}.json --profile ${DP_PROFILE}

# Assign the IDBroker mapping
cdp environments set-id-broker-mappings --cli-input-json file://mappings.json --profile ${CDP_PROFILE} ${CDP_CORE}

# Assign the special cdp admin group to be both users and admins of this environment
export CDP_ENVIRONMENT_CRN=`cdp environments describe-environment --environment-name ${DATALAKE} --profile ${CDP_PROFILE} ${CDP_CORE} | jq .environment.crn -r`

cdp iam assign-group-resource-role --group-name ${CDP_ADMIN_GROUP} --profile ${CDP_PROFILE} ${CDP_IAM} --resource-role "crn:altus:iam:us-west-1:altus:resourceRole:EnvironmentAdmin" --resource-crn ${CDP_ENVIRONMENT_CRN}

cdp iam assign-group-resource-role --group-name ${CDP_ADMIN_GROUP} --profile ${CDP_PROFILE} ${CDP_IAM} --resource-role "crn:altus:iam:us-west-1:altus:resourceRole:EnvironmentUser" --resource-crn ${CDP_ENVIRONMENT_CRN}

# Create a data-lake
cdp datalake create-aws-datalake --cli-input-json file://dldefn.json --profile ${CDP_PROFILE} ${CDP_CORE}
# As easy as that!

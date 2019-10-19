#!/usr/bin/env bash

. common-vars.sh


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
# cdp datalake create-aws-datalake --cli-input-json file://dldefn.json --profile ${CDP_PROFILE} ${CDP_CORE}
# As easy as that!

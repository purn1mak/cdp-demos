#!/usr/bin/env bash
# which environment would you like to cleanup?
. common-vars.sh

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

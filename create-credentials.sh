#!/usr/bin/env bash

. common-vars.sh

# Create AWS credentials by specifying a delegated role,Cloudera will assume that role.

cdp environments create-aws-credential \
--credential-name 'hf-aws-cross-account-role-01' \
--description 'optional credential description' \
--role-arn 'arn:aws:iam::007856030109:role/hfulambarkar-sandbox-role'


cdp environments create-aws-environment \
--environment-name 'pk-cldr-cdp' \
--credential-name 'pk-cldr-cdp' \
--description 'AWS environment with auto-generated network' \
--region 'us-west-2' \
--network-cidr '10.40.0.0/16' \
--security-access cidr='10.40.0.0/16' \
--authentication publicKeyId='pk-uswest2' \
--log-storage ''
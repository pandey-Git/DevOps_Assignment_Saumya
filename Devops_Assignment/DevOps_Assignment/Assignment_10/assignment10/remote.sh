#!/bin/bash

BUCKET="accesspoint-$(date +%s)"

aws s3 mb s3://$BUCKET

echo "Bucket created: $BUCKET"

aws s3control create-access-point \
--account-id 500692702174 \
--name myaccesspoint \
--bucket $BUCKET \
--region ap-northeast-1

echo "Access point created"

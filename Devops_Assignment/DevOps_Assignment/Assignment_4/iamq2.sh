#!/bin/bash

aws iam create-role --role-name Tester-role \
--assume-role-policy-document '{
"Version":"2012-10-17",
"Statement":[{
"Effect":"Allow",
"Principal":{"Service":"ec2.amazonaws.com"},
"Action":"sts:AssumeRole"
}]}'

aws iam create-policy --policy-name Tester-Policy \
--policy-document '{
"Version":"2012-10-17",
"Statement":[{
"Effect":"Allow",
"Action":["s3:GetObject","s3:ListBucket"],
"Resource":"*"
}]}'

aws iam attach-role-policy \
--role-name Tester-role \
--policy-arn arn:aws:iam::500692702174:policy/Tester-Policy

echo "Role and policy created successfully"

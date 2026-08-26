#!/bin/bash

BUCKET="mybucket-$(date +%s)"

aws s3 mb s3://$BUCKET

echo "Hello S3" > script.txt

aws s3 cp script.txt s3://$BUCKET

echo "Bucket contents:"
aws s3 ls s3://$BUCKET

aws s3 rb s3://$BUCKET --force

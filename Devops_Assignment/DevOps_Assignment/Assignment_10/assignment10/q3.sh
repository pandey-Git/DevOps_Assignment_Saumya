#!/bin/bash

BUCKET="mywebsite-$(date +%s)"

aws s3 mb s3://$BUCKET

echo "<h1>Hello from S3</h1>" > index.html

aws s3 cp index.html s3://$BUCKET

aws s3 website s3://$BUCKET --index-document index.html

echo "Website: http://$BUCKET.s3-website-ap-northeast-1.amazonaws.com"

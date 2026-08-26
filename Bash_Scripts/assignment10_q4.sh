#!/bin/bash

AMI="ami-0e239f7f4b3226722"
KEY="terraform-key"
SG="sg-0469fcb003b8da5bf"

ID=$(aws ec2 run-instances \
--image-id $AMI \
--instance-type t3.micro \
--key-name $KEY \
--subnet-id subnet-004a8538d44da7f9d \
--security-group-ids $SG \
--query 'Instances[0].InstanceId' \
--output text)

echo "Instance ID: $ID"

aws ec2 wait instance-running --instance-ids $ID

DNS=$(aws ec2 describe-instances \
--instance-ids $ID \
--query 'Reservations[0].Instances[0].PublicDnsName' \
--output text)

echo "Public DNS: $DNS"

scp -i /Users/skpandey/Downloads/terraform-key.pem remote.sh ubuntu@$DNS:/home/ubuntu/

ssh -i /Users/skpandey/Downloads/terraform-key.pem ubuntu@$DNS "chmod +x remote.sh && ./remote.sh"

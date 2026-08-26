#!/bin/bash

id=$(aws ec2 run-instances --image-id ami-0f7e90d3283d2e250 --instance-type t3.micro --count 1 --query 'Instances[0].InstanceId' --output text)

echo "Instance ID: $id"

sleep 10

aws ec2 describe-instances --instance-ids $id --query 'Reservations[0].Instances[0].[PublicIpAddress,PublicDnsName]' --output table

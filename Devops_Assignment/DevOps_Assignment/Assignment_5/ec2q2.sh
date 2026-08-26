#!/bin/bash

id=$(aws ec2 run-instances --image-id ami-0f7e90d3283d2e250 --instance-type t3.micro --count 1 --query 'Instances[0].InstanceId' --output text)

echo "Instance ID: $id"

sleep 10

ip=$(aws ec2 describe-addresses --query 'Addresses[?InstanceId==`'$id'`].PublicIp' --output text)

if [ -z "$ip" ]
then
    echo "No Elastic IP is assigned"
else
    echo "Elastic IP: $ip"
fi

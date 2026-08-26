#!/bin/bash
source vars.env
echo "===== VPC AUDIT $(date) =====" >> vpc_audit.log
echo "NAT Gateway:" >> vpc_audit.log
aws ec2 describe-nat-gateways --nat-gateway-ids nat-06d9c60b3cc0b5107 --output text >> vpc_audit.log
echo "Instances:" >> vpc_audit.log
aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" --output text >> vpc_audit.log
echo "============================" >> vpc_audit.log

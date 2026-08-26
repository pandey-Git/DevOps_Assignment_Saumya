#!/bin/bash

source vars.env

create_vpc() {
    if aws ec2 describe-vpcs --vpc-ids "$VPC_ID" >/dev/null 2>&1; then
        echo "VPC already exists: $VPC_ID"
    else
        VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query "Vpc.VpcId" --output 
text)
        echo "VPC_ID=$VPC_ID" >> vars.env
        echo "VPC created: $VPC_ID"
    fi
}

create_subnets() {
    if aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" >/dev/null 2>&1; then
        echo "Subnets already exist"
    else
        echo "Subnets need to be created"
    fi
}

setup_igw_and_route() {
    if aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" 
>/dev/null 2>&1; then
        echo "Internet Gateway already exists"
    else
        echo "Internet Gateway needs to be created"
    fi
}

setup_nat_and_route() {
    if aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" >/dev/null 2>&1; 
then
        echo "NAT Gateway already exists"
    else
        echo "NAT Gateway needs to be created"
    fi
}

launch_instances() {
    if aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" >/dev/null 2>&1; 
then
        echo "EC2 instances already exist"
    else
        echo "EC2 instances need to be created"
    fi
}

create_vpc
create_subnets
setup_igw_and_route
setup_nat_and_route
launch_instances

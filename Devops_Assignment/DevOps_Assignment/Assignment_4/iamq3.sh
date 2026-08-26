#!/bin/bash

aws iam create-user --user-name Test2

aws iam create-group --group-name testing

aws iam add-user-to-group --user-name Test --group-name testing

aws iam add-user-to-group --user-name Test2 --group-name testing

aws iam attach-group-policy --group-name testing \
--policy-arn arn:aws:iam::500692702174:policy/Tester-Policy

echo "Users added to testing group"

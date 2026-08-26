#!/bin/bash

aws iam create-user --user-name Test

aws iam attach-user-policy --user-name Test --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

echo "Test user created and Administrator access added"

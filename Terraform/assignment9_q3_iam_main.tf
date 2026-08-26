terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# Create IAM User
resource "aws_iam_user" "devuser" {
  name = "devuser"

  tags = {
    Name = "DevUser"
  }
}

# Attach AdministratorAccess policy
resource "aws_iam_user_policy_attachment" "admin_access" {
  user       = aws_iam_user.devuser.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Attach AmazonEC2FullAccess policy
resource "aws_iam_user_policy_attachment" "ec2_full_access" {
  user       = aws_iam_user.devuser.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

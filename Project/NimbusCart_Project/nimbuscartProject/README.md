# NimbusCart — Three-Tier AWS Application

This project implements the assignment using:
- Nginx + static HTML/JS on a public Web EC2 instance.
- Flask REST API in a Docker container on a private App EC2 instance.
- MySQL on a private RDS instance inside an isolated Data VPC.
- VPC peering between the Web/App VPC and Data VPC.
- NAT Gateway for outbound access from the private App subnet.
- Terraform with S3 remote state and DynamoDB locking.
- Terraform file/remote-exec provisioners and a local-exec image build/push step.

## Before Terraform

1. Create the S3 bucket and DynamoDB table used for remote state.
2. Replace the placeholders in `terraform/backend.tf`.
3. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`.
4. Set the correct Ubuntu AMI ID, EC2 key pair name, private key path, and DB password.
5. Ensure AWS CLI, Terraform, Docker and AWS credentials are available on the machine running Terraform.

## Run

From the project root:

```bash
./script.sh
```

The script intentionally runs only Terraform init, plan and apply as required by the assignment.

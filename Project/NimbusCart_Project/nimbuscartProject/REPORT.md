# NimbusCart Report

## 1. Project overview
NimbusCart is a three-tier product-catalog application. The Web tier serves the frontend with nginx, the App tier runs a Dockerized Flask REST API, and the Data tier uses a private MySQL RDS instance.

## 2. API technology
The API is implemented using **Flask** and runs in a single Docker container.

## 3. Architecture
- Web/App VPC: public web subnet + private app subnet.
- Data VPC: two private DB subnets in two AZs.
- VPC peering connects the application VPC and the data VPC.
- App subnet uses the NAT Gateway for outbound internet access.
- Data VPC has no NAT Gateway.

## 4. Manual peering test
### Missing return route
When the data VPC route table does not contain a route back to the application VPC CIDR through the peering connection, packets from the App VPC can reach the Data VPC interface, but return traffic has no matching route back. The connection test therefore fails in the return direction.

### Why no NAT is needed in the DB subnet
The DB subnet only needs to be reachable from the application VPC; it does not need to initiate internet-bound connections. VPC peering provides private routed connectivity between the VPC CIDRs, so a NAT Gateway is unnecessary in the isolated Data VPC.

## 5. Conceptual questions
### Q1. Why must the DB subnet group span multiple AZs even for a single-AZ RDS instance?
RDS DB subnet groups are expected to contain subnets in at least two Availability Zones. This gives RDS subnet placement options even when the actual DB instance is configured as single-AZ.

### Q2. VPC Peering vs Transit Gateway
VPC peering is simple and suitable for a small number of VPCs, but each additional VPC requires individual peering relationships. Transit Gateway is better when many VPCs need hub-and-spoke connectivity and centralized routing.

### Q3. How does the private App tier authenticate to ECR?
The App EC2 instance has an IAM role with ECR read permissions. Its private subnet sends outbound traffic through the NAT Gateway. The instance uses the AWS CLI to obtain an ECR authorization token and then Docker pulls the private image.

### Q4. Security groups vs NACLs
Security groups are stateful, so return traffic for an allowed connection is automatically permitted. NACLs are stateless, so both the forward and return traffic must be explicitly allowed. A missing ephemeral-port return rule can therefore break an otherwise valid connection.

### Q5. Why are local-exec provisioners discouraged?
Terraform tracks the provisioner resource execution but does not model every external side effect produced by arbitrary shell commands. This can reduce reproducibility and drift visibility. For this assignment, using local-exec for the image build/push is acceptable because the image-build step is a deliberate bridge between local Docker tooling and the ECR repository.

### Q6. Why does backend.tf not live in the same state it configures?
The state backend must exist before Terraform can store the state in it. Keeping backend bootstrap outside that state avoids a circular dependency where Terraform needs remote state before it can create the resources required to host that remote state.

## 6. Required screenshots
Insert screenshots in this section with captions:
1. Local `/health` test.
2. Local GET `/api/items` and database table.
3. Local POST `/api/items`.
4. Local frontend with product.
5. Docker build and running container.
6. Terraform init/plan/apply.
7. VPCs and subnets.
8. VPC peering and routes.
9. NAT Gateway.
10. EC2 Web and App instances.
11. ECR repository and image.
12. RDS instance and DB subnet group.
13. Failed connectivity with missing data-VPC return route.
14. Successful connectivity after restoring the route.
15. `terraform output`.
16. Final NimbusCart frontend URL with product added.

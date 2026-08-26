terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.57.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  az_a      = data.aws_availability_zones.available.names[0]
  az_b      = data.aws_availability_zones.available.names[1]
  ecr_repo  = "${var.project_name}-api"
  image_uri = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.ecr_repo}:latest"
}

# -------------------- Web/App VPC --------------------
resource "aws_vpc" "web_app" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project_name}-web-app-vpc" }
}

resource "aws_internet_gateway" "web_app" {
  vpc_id = aws_vpc.web_app.id
  tags   = { Name = "${var.project_name}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.web_app.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = local.az_a
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project_name}-public-subnet" }
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.web_app.id
  cidr_block        = var.app_subnet_cidr
  availability_zone = local.az_a
  tags              = { Name = "${var.project_name}-app-subnet" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.web_app.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_app.id
  }
  tags = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.project_name}-nat-eip" }
}

resource "aws_nat_gateway" "app" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.web_app]
  tags          = { Name = "${var.project_name}-nat" }
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.web_app.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app.id
  }
  tags = { Name = "${var.project_name}-app-rt" }
}

resource "aws_route_table_association" "app" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.app.id
}

# -------------------- Data VPC --------------------
resource "aws_vpc" "data" {
  cidr_block           = var.data_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project_name}-data-vpc" }
}

resource "aws_subnet" "data_a" {
  vpc_id            = aws_vpc.data.id
  cidr_block        = var.data_subnet_a_cidr
  availability_zone = local.az_a
  tags              = { Name = "${var.project_name}-data-subnet-a" }
}

resource "aws_subnet" "data_b" {
  vpc_id            = aws_vpc.data.id
  cidr_block        = var.data_subnet_b_cidr
  availability_zone = local.az_b
  tags              = { Name = "${var.project_name}-data-subnet-b" }
}

resource "aws_route_table" "data" {
  vpc_id = aws_vpc.data.id
  tags   = { Name = "${var.project_name}-data-rt" }
}

resource "aws_route_table_association" "data_a" {
  subnet_id      = aws_subnet.data_a.id
  route_table_id = aws_route_table.data.id
}

resource "aws_route_table_association" "data_b" {
  subnet_id      = aws_subnet.data_b.id
  route_table_id = aws_route_table.data.id
}

# -------------------- Peering --------------------
resource "aws_vpc_peering_connection" "web_to_data" {
  vpc_id      = aws_vpc.web_app.id
  peer_vpc_id = aws_vpc.data.id
  auto_accept = true
  tags        = { Name = "${var.project_name}-web-data-peering" }
}

resource "aws_route" "app_to_data" {
  route_table_id            = aws_route_table.app.id
  destination_cidr_block    = var.data_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.web_to_data.id
}

resource "aws_route" "data_to_app" {
  route_table_id            = aws_route_table.data.id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.web_to_data.id
}

# -------------------- Security Groups --------------------
resource "aws_security_group" "web" {
  name   = "${var.project_name}-web-sg"
  vpc_id = aws_vpc.web_app.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name   = "${var.project_name}-app-sg"
  vpc_id = aws_vpc.web_app.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name   = "${var.project_name}-db-sg"
  vpc_id = aws_vpc.data.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.app_subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.20.0.0/16"]
  }
}

# -------------------- IAM for App EC2 --------------------
resource "aws_iam_role" "app_ec2" {
  name = "${var.project_name}-app-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_push" {
  role       = aws_iam_role.app_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-app-profile"
  role = aws_iam_role.app_ec2.name
}

# -------------------- ECR --------------------
resource "aws_ecr_repository" "api" {
  name                 = local.ecr_repo
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# -------------------- RDS --------------------
resource "aws_db_subnet_group" "data" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.data_a.id, aws_subnet.data_b.id]
  tags       = { Name = "${var.project_name}-db-subnet-group" }
}

resource "aws_db_instance" "mysql" {
  identifier              = "${var.project_name}-mysql"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp3"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.data.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0
  multi_az                = false
  depends_on              = [aws_route.data_to_app]
}

# -------------------- EC2 instances --------------------
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  tags                        = { Name = "${var.project_name}-web" }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.app.id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.app.name
  key_name               = var.key_name
  tags                   = { Name = "${var.project_name}-app" }

  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = file(pathexpand(var.private_key_path))
    host                = self.private_ip
    bastion_host        = aws_instance.web.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file(pathexpand(var.private_key_path))
  }

  provisioner "file" {
    source      = "${path.module}/../app/api"
    destination = "/home/ubuntu/api"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io awscli",
      "sudo systemctl enable --now docker",
      "aws ecr get-login-password --region ${var.region} | sudo docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com",
      "cd /home/ubuntu/api && sudo docker build -t ${local.ecr_repo}:latest .",
      "sudo docker tag ${local.ecr_repo}:latest ${local.image_uri}",
      "sudo docker push ${local.image_uri}",
      "sudo docker rm -f nimbus-api || true",
      "sudo docker run -d --restart unless-stopped --name nimbus-api -p 5000:5000 -e DB_HOST=${aws_db_instance.mysql.address} -e DB_PORT=3306 -e DB_USER=${var.db_username} -e DB_PASSWORD='${var.db_password}' -e DB_NAME=${var.db_name} ${local.image_uri}"
    ]
  }

  depends_on = [aws_db_instance.mysql, aws_route.app_to_data, aws_route.data_to_app, aws_ecr_repository.api]
}

resource "null_resource" "configure_web" {
  depends_on = [aws_instance.web, aws_instance.app]

  triggers = {
    web_ip = aws_instance.web.public_ip
    app_ip = aws_instance.app.private_ip
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand(var.private_key_path))
    host        = aws_instance.web.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/../app/frontend/index.html"
    destination = "/tmp/index.html"
  }

  provisioner "file" {
    content     = <<-NGINX
      server {
        listen 80 default_server;
        server_name _;
        root /var/www/nimbuscart;
        index index.html;

        location / {
          try_files $uri $uri/ /index.html;
        }

        location /health {
          proxy_pass http://${aws_instance.app.private_ip}:5000;
          proxy_set_header Host $host;
        }

        location /api/ {
 	  proxy_pass http://${aws_instance.app.private_ip}:5000/;
 	  proxy_set_header Host $host;
 	  proxy_set_header X-Real-IP $remote_addr;
	}
    NGINX
    destination = "/tmp/nimbuscart.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo mkdir -p /var/www/nimbuscart",
      "sudo cp /tmp/index.html /var/www/nimbuscart/index.html",
      "sudo cp /tmp/nimbuscart.conf /etc/nginx/sites-available/nimbuscart",
      "sudo ln -sf /etc/nginx/sites-available/nimbuscart /etc/nginx/sites-enabled/nimbuscart",
      "sudo rm -f /etc/nginx/sites-enabled/default",
      "sudo nginx -t",
      "sudo systemctl restart nginx"
    ]
  }
}

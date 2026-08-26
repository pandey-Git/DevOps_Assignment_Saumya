provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_security_group" "nginx" {
  name = "terraform-nginx-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "webserver" {
  ami           = "ami-0e239f7f4b3226722"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.nginx.id]

  user_data = file("${path.module}/provisioners.sh")

  tags = {
    Name = "Terraform-Nginx-Server"
  }
}

output "public_ip" {
  value = aws_instance.webserver.public_ip
}

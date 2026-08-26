variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "project_name" {
  type    = string
  default = "nimbuscart"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "data_vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "app_subnet_cidr" {
  type    = string
  default = "10.10.2.0/24"
}

variable "data_subnet_a_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "data_subnet_b_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

variable "key_name" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "db_username" {
  type    = string
  default = "nimbus"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "nimbuscart"
}

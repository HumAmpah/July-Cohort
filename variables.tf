variable "region" {
  description = "AWS region"
}

variable "environment" {
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Public Subnet"
}

variable "private_subnets_cidr" {
  type = list(any)
  description = "CIDR block for Private Subnet"
}


variable "availability_zones" {
 type        = list(string)
 description = "Availability Zones"
}

variable "aws_ecr_image" {
 description = "aws ecr image"
}

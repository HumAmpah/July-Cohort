variable "region" {
  description = "AWS region"
  default = "eu-west-2"
}


variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  default = [ "10.0.1.0/24", "10.0.2.0/24" ]
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  default = [ "eu-west-2a","eu-west-2b" ]
  type        = list(string)
}



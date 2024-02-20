provider "aws" {
    region = "var.region"  
    profile = "terraform-modules"
}

# Create VPC
module "vpc" {
  source                 = "../modules/vpc"
   region = "eu-west-2"

environment = "pro"

vpc_cidr = "10.0.0.0/16"

public_subnets_cidr = ["10.0.0.0/20", "10.0.128.0/20"]
  
private_subnets_cidr = ["10.0.16.0/20", "10.0.96.0/20"]

availability_zones = ["eu-west-2a", "eu-west-2b"]
 
aws_ecr_image = "ecommerce"

}



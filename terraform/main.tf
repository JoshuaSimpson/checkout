provider "aws" {
  region = var.region
}

locals {
  environment = "interview"
}

terraform {
    backend "s3" {
        bucket = "terraform-checkout"
        key    = "state.tfstate"
    }
}

data "aws_route53_zone" "selected" {
  name         = var.domain
  private_zone = false
}

# ----- VPC -----
# The VPC is large, and full of subnets, so let's use AWS' module for this
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "checkout-vpc-${local.environment}"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Because I don't want to get bankrupted by AWS if I forget to destroy this
  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = local.environment
  }
}


# ----- ECS -----
module "backend" {
  # Cluster config
  source = "./backend"
  environment = local.environment
  vpc_id = module.vpc.vpc_id
  cluster_name = var.cluster_name
  subnets = module.vpc.public_subnets
  min_instances = 1
  max_instances = 10
  desired_instances = 3

  # DNS config
  zone_id = data.aws_route53_zone.selected.zone_id
  root_domain = data.aws_route53_zone.selected.name
  subdomain = var.api-subdomain
  
  # Service config
  service_name = var.service_name
  desired_containers = 3
  log_retention_in_days = 30

  region = var.region
}

module "frontend" {
  source = "./frontend"
  domain = "${local.environment}.${data.aws_route53_zone.selected.name}"
  environment = local.environment
  zone_id = data.aws_route53_zone.selected.zone_id
}

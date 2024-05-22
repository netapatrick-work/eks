provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "eks-private-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway   = false
  enable_internet_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }
}

resource "aws_security_group" "eks_control_plane" {
  name_prefix = "eks-control-plane-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.3"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.24"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    default_node_group = {
      instance_types = ["m5.large"]
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.eks_control_plane.id]

  endpoints = {
    s3 = {
      service_name        = "com.amazonaws.${data.aws_region.current.name}.s3"
      service_type        = "Gateway"
      route_table_ids     = module.vpc.private_route_table_ids
      private_dns_enabled = true
    },

    ecr_api = {
      service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
      private_dns_enabled = true
    },

    ecr_dkr = {
      service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
      private_dns_enabled = true
    },

    ec2 = {
      service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2"
      private_dns_enabled = true
    }
  }
}

data "aws_region" "current" {}

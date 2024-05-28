module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.11.0"

  cluster_name    = "${var.name_prefix}-cluster"
  cluster_version = "1.27"

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.public.ids  #module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 1
      desired_size   = 1
    }
  }
}
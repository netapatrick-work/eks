provider "aws" {
  region = "us-west-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "cluster_security_group" {
  name_prefix = "eks-cluster-sg-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.worker_node_security_group.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "worker_node_security_group" {
  name_prefix = "eks-worker-node-sg-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.cluster_security_group.id]
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
  version = "19.5.1"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.24"

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnet_ids.default.ids

  cluster_security_group_id = aws_security_group.cluster_security_group.id
  worker_security_group_id  = aws_security_group.worker_node_security_group.id

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}


# Cluster Ingress Security Group
output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  value       = module.eks.worker_security_group_id
}

resource "aws_security_group_rule" "cluster_ingress_worker_node_security_group" {
  description              = "Allow worker nodes to communicate with the EKS cluster API."
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = module.eks.worker_security_group_id
  type                     = "ingress"
}
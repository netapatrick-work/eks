## Amazon EKS Cluster

Derives from the aws eks blueprints - https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/patterns/

Creates an EKS cluster with an ASG ranging from 1 - 3 nodes (min:1, desired:1, max 3).
The following addons/resources are also installed in/created with the cluster:
* kube-proxy, vpc-cni, coredns addons
* AWS Load Balancer Controller
* Cluster AutoScaler
* S3 bucket (for use of Loki s3 storage option)
* An ECR repository (intended for storing cluster operator/installer image)


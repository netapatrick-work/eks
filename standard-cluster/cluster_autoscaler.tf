data "aws_iam_policy_document" "cluster_autoscaler_policy" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "cluster-autoscaler-policy"
  description = "Permissions required for Cluster Autoscaler"
  policy      = data.aws_iam_policy_document.cluster_autoscaler_policy.json
}

resource "aws_iam_role" "cluster_autoscaler_role" {
  name = "cluster-autoscaler-role"

  # Trust policy to allow the Kubernetes service account to assume the role
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_issuer_url}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.oidc_issuer_url}:sub": "system:serviceaccount:kube-system:cluster-autoscaler-aws-cluster-autoscaler",
            "${local.oidc_issuer_url}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_policy_attachment" {
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
  role       = aws_iam_role.cluster_autoscaler_role.name
}

resource "helm_release" "cluster_autoscaler" {
  depends_on = [module.eks]
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = data.aws_eks_cluster.cluster.name
  }

  set {
    name  = "awsRegion"
    value = "${data.aws_region.current.name}"
  }

  set {
    name  = "extraArgs.node-group-auto-discovery"
    value = "asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${data.aws_eks_cluster.cluster.name}=owned"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler_role.arn
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi_iam_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
 
  tags = merge(
    {
      Name = "addon-aws-ebs-csi-driver"
    },
    var.common_tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_iam_role_policy_attach,
    aws_eks_node_group.eks_node_group,
    aws_eks_fargate_profile.fargate_profile
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"

  tags = merge(
    {
      Name = "addon-coredns"
    },
    var.common_tags
  )

  depends_on = [ 
    aws_eks_node_group.eks_node_group,
    aws_eks_fargate_profile.fargate_profile
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"

  tags = merge(
    {
      Name = "addon-kube-proxy"
    },
    var.common_tags
  )

  depends_on = [ 
    aws_eks_node_group.eks_node_group,
    aws_eks_fargate_profile.fargate_profile
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"

  tags = merge(
    {
      Name = "addon-vpc-cni"
    },
    var.common_tags
  )

  depends_on = [ 
    aws_eks_node_group.eks_node_group,
    aws_eks_fargate_profile.fargate_profile
  ]
}

resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "aws-efs-csi-driver"
  service_account_role_arn    = aws_iam_role.efs_csi_iam_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
 
  tags = merge(
    {
      Name = "addon-aws-efs-csi-driver"
    },
    var.common_tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.efs_csi_iam_role_policy_attach,
    aws_eks_node_group.eks_node_group,
    aws_eks_fargate_profile.fargate_profile
  ]
}

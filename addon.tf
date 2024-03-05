resource "aws_eks_addon" "csi_driver" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi_iam_role.arn

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_iam_role_policy_attach,
    aws_eks_node_group.eks_node_group
  ]
 

  tags = merge(
    {
      Name = "addon-aws-ebs-csi-driver"
    },
    var.common_tags
  )
}
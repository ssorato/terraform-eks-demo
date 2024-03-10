resource "aws_eks_fargate_profile" "fargate_profile" {
  for_each = var.eks_nodes.fargate != null ? {
    for k,v in var.eks_nodes.fargate :
      v.profile_name => v
  } : {}

  cluster_name           = aws_eks_cluster.eks_cluster.name
  fargate_profile_name   = "${var.eks_name}-fp-${each.key}"
  pod_execution_role_arn = aws_iam_role.fargate_role[0].arn
  subnet_ids =  aws_subnet.eks_private_subnet[*].id

  selector {
    namespace = each.value.namespace
    labels    = each.value.labels
  }

  tags = merge(
    {
      Name = "${var.eks_name}-fp-${each.key}"
    },
    var.common_tags
  )
}

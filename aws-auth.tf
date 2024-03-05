locals {
  configmap_roles = var.create_sample_users ? [
    {
      rolearn = "${aws_iam_role.eks_node_role.arn}"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = [
        "system:bootstrappers",
        "system:nodes"
      ]
    },
    {
      rolearn = "${aws_iam_role.eks_admin_role[0].arn}"
      username = "${aws_iam_role.eks_admin_role[0].name}"
      groups   = ["${var.eks_name}-admin-group"]
    }
  ] : [
    {
      rolearn = "${aws_iam_role.eks_node_role.arn}"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]
  configmap_users = var.create_sample_users ? [
    {
      userarn  = "${aws_iam_user.eksreader1[0].arn}"
      username = "${aws_iam_user.eksreader1[0].name}"
      groups   = ["${var.eks_name}-readonly-group"]
    }
  ] : []
}

resource "kubernetes_config_map_v1" "aws_auth" {
  depends_on = [
    aws_eks_cluster.eks_cluster,
    kubernetes_cluster_role_v1.eksreadonly_clusterrole[0]
  ]
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode(local.configmap_roles)
    mapUsers = var.create_sample_users ? yamlencode(local.configmap_users) : null
  }  
}

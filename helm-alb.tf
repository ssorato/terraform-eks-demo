#
# AWS Load Balancer controller
# IngressClasses: alb
#
resource "helm_release" "albc_controller" {
  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_node_group,
    kubernetes_config_map_v1.aws_auth,
    aws_iam_role.albc_iam_role
  ]        
  name       = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"     

  # https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  set {
    name = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller" 
  }       

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.albc_iam_role.arn
  }

  set {
    name  = "vpcId"
    value = aws_vpc.eks_vpc.id
  }  

  set {
    name  = "region"
    value = var.aws_region
  }    

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks_cluster.name
  }    


}

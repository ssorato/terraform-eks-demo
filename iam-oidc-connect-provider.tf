resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.eks_cluster.certificates.0.sha1_fingerprint, 
    var.eks_oidc_thumbprint
  ]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  tags = merge(
    {
      Name = "${var.eks_name}-irsa"
    },
    var.common_tags
  )
}

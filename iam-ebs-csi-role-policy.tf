resource "aws_iam_role" "ebs_csi_iam_role" {
  name = "${var.eks_name}-ebs-csi-drive-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
        }
        Condition = {
          StringEquals = { 
            "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:aud": "sts.amazonaws.com",           
            "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }        

      },
    ]
  })

  tags = merge(
    {
      Name = "${var.eks_name}-ebs-csi-drive-iam-role"
    },
    var.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "ebs_csi_iam_role_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" 
  role       = aws_iam_role.ebs_csi_iam_role.name
}

resource "aws_iam_role" "efs_csi_iam_role" {
  name = "${var.eks_name}-AmazonEKS_EFS_CSI_DriverRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
        }
        Condition = {
          StringEquals = { 
            "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:aud": "sts.amazonaws.com",           
            "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }        

      },
    ]
  })

  tags = merge(
    {
      Name = "${var.eks_name}-AmazonEKS_EFS_CSI_DriverRole"
    },
    var.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "efs_csi_iam_role_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy" 
  role       = aws_iam_role.efs_csi_iam_role.name
}

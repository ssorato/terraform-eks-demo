#
# EKS admin role
#
resource "aws_iam_role" "eks_admin_role" {
  count = var.create_sample_users ? 1 : 0
  name = "eks-admin-role-${var.eks_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
    ]
  })   

  tags = merge(
    {
      Name = "eks-admin-role-${var.eks_name}"
    },
    var.common_tags
  )
}

#
# Read-only user
#
resource "pgp_key" "eksreader1" {
  count = var.create_sample_users ? 1 : 0
  name    = "eksreader1"
  email   = "eksreader1@local.domain"
  comment = "eksreader1 create by Terraform"
}

resource "aws_iam_user" "eksreader1" {
  count = var.create_sample_users ? 1 : 0
  name = "${var.eks_name}-eksreader1"
  path = "/"
  force_destroy = true
  tags = merge(
    {
      Name = "${var.eks_name}-eksreader1"
    },
    var.common_tags
  )
}

resource "aws_iam_user_login_profile" "eksreader1" {
  count = var.create_sample_users ? 1 : 0
  user    = aws_iam_user.eksreader1[0].name
  pgp_key = pgp_key.eksreader1[0].public_key_base64
}

resource "aws_iam_access_key" "eksreader1" {
  count = var.create_sample_users ? 1 : 0
  user    = aws_iam_user.eksreader1[0].name
  pgp_key = pgp_key.eksreader1[0].public_key_base64
}

resource "aws_iam_policy" "read_eks_policy" {
  count = var.create_sample_users ? 1 : 0
  name =       "${var.eks_name}-eks-read-policy"
  description = "EKS ${var.eks_name} read plocy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "ssm:GetParameter",
          "eks:ListUpdates",
          "eks:ListFargateProfiles"
        ]
        Effect   = "Allow"
        Resource = "${aws_eks_cluster.eks_cluster.arn}"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "eksreader1_attached_policy" {
  count = var.create_sample_users ? 1 : 0
  user       = aws_iam_user.eksreader1[0].name
  policy_arn = aws_iam_policy.read_eks_policy[0].arn
}

#
# EKS full access group
#
resource "aws_iam_policy" "admin_eks_policy" {
  count = var.create_sample_users ? 1 : 0
  name =       "${var.eks_name}-eks-admin-policy"
  description = "EKS ${var.eks_name} admin plocy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:*"
        ]
        Effect   = "Allow"
        Resource = "${aws_eks_cluster.eks_cluster.arn}"
      },
      {
        "Effect": "Allow",
        "Action": "iam:PassRole",
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "iam:PassedToService": "eks.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_role_attached_policy" {
  count = var.create_sample_users ? 1 : 0
  policy_arn = aws_iam_policy.admin_eks_policy[0].arn
  role       = aws_iam_role.eks_admin_role[0].name
}

resource "aws_iam_group" "eksadmins_iam_group" {
  count = var.create_sample_users ? 1 : 0
  name = "${var.eks_name}-eksadmins"
  path = "/"
}

resource "aws_iam_group_policy" "eksadmins_iam_group_assumerole_policy" {
  count = var.create_sample_users ? 1 : 0
  name  = "${var.eks_name}-eksadmins-group-policy"
  group = aws_iam_group.eksadmins_iam_group[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Sid    = "AllowAssumeOrganizationAccountRole"
        Resource = "${aws_iam_role.eks_admin_role[0].arn}"
      },
    ]
  })
}

#
# EKS full access user
#
resource "pgp_key" "eksadmin1" {
  count = var.create_sample_users ? 1 : 0
  name    = "eksadmin1"
  email   = "eksadmin1@local.domain"
  comment = "eksadmin1 create by Terraform"
}

resource "aws_iam_user" "eksadmin1" {
  count = var.create_sample_users ? 1 : 0
  name = "${var.eks_name}-eksadmin1"
  path = "/"
  force_destroy = true
  tags = merge(
    {
      Name = "${var.eks_name}-eksadmin1"
    },
    var.common_tags
  )  
}

resource "aws_iam_group_membership" "eksadmins" {
  count = var.create_sample_users ? 1 : 0
  name = "${var.eks_name}-eksadmins-group-membership"
  users = [
    aws_iam_user.eksadmin1[0].name
  ]
  group = aws_iam_group.eksadmins_iam_group[0].name
}

resource "aws_iam_user_login_profile" "eksadmin1" {
  count = var.create_sample_users ? 1 : 0
  user    = aws_iam_user.eksadmin1[0].name
  pgp_key = pgp_key.eksadmin1[0].public_key_base64
}

resource "aws_iam_access_key" "eksadmin1" {
  count = var.create_sample_users ? 1 : 0
  user    = aws_iam_user.eksadmin1[0].name
  pgp_key = pgp_key.eksadmin1[0].public_key_base64
}

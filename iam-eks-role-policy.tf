#
# EKS cluster IAM role
#

resource "aws_iam_role" "eks_control_plane_role" {
  name = "control-plane-role-${var.eks_name}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = merge(
    {
      Name = "control-plane-role-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "eks_control_plane_role_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_control_plane_role.name
}

resource "aws_iam_role_policy_attachment" "eks_control_plane_role_vpc_resource" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_control_plane_role.name
}

#
# Node IAM role
#

resource "aws_iam_role" "eks_node_role" {
  name = "node-role-${var.eks_name}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = merge(
    {
      Name = "control-plane-role-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "eks_node_role_eks_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_role_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_role_container_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

#
# EBS CSI drivers
#
resource "aws_iam_role" "ebs_csi_iam_role" {
  name = "ebs-csi-drive-iam-role-${var.eks_name}"

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
      Name = "ebs-csi-drive-iam-role-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "ebs_csi_iam_role_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" 
  role       = aws_iam_role.ebs_csi_iam_role.name
}


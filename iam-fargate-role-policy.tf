resource "aws_iam_role" "fargate_role" {
  count = var.eks_nodes.fargate == null ? 0 : 1
  name = "${var.eks_name}-AmazonEKSFargatePodExecutionRole"

  assume_role_policy = jsonencode({
    Statement = [
    {
      "Effect": "Allow",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "${replace(aws_eks_cluster.eks_cluster.arn, "cluster", "fargateprofile")}/*"
        }
      },
      "Principal": {
        "Service": "eks-fargate-pods.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution_role_policy" {
  count = var.eks_nodes.fargate == null ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_role[0].name
}

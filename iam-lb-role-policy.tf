resource "aws_iam_policy" "albc_iam_policy" {         
  name        = "${var.eks_name}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWS Load Balancer Controller IAM Policy"                                                                                              
  policy = file("aws_lb_controller_iam_policy.json")         
}

resource "aws_iam_role" "albc_iam_role" {
  name = "${var.eks_name}-albc-iam-role"

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
            "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }        
      },
    ]
  })

  tags = merge(
    {
      Name = "${var.eks_name}-AWSLoadBalancerControllerIAMPolicy"
    },
    var.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "albc_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.albc_iam_policy.arn 
  role       = aws_iam_role.albc_iam_role.name
}

resource "aws_security_group" "eks_control_plane_sg" {
  name = "control-plane-sg-${var.eks_name}"
  description = "Communication with eks nodes and EKS control plane"
  vpc_id = aws_vpc.eks_vpc.id

  tags = merge(
    {
      Name = "control-plane-sg-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_security_group_rule" "eks_control_plane_sg_ingress_rule" {
  security_group_id = aws_security_group.eks_control_plane_sg.id
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  source_security_group_id = aws_security_group.nodes_sg.id
  type              = "ingress"
  description       = "Communication to the EKS control plane from EKS nodes"
}

resource "aws_security_group_rule" "eks_control_plane_sg_egress_rule" {
  security_group_id = aws_security_group.eks_control_plane_sg.id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
  description       = "Communication from the EKS control plane"
}


resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_name
  role_arn = aws_iam_role.eks_control_plane_role.arn
  version  = var.k8s_version

  vpc_config {
    subnet_ids              = var.eks_private_nodes ? aws_subnet.eks_private_subnet[*].id : aws_subnet.eks_public_subnet[*].id
    endpoint_public_access  = true
    endpoint_private_access = true
    security_group_ids      = [aws_security_group.eks_control_plane_sg.id]
    public_access_cidrs     = var.eks_private_nodes ? [
      "${chomp(data.http.my_public_ip.response_body)}/32",
      "${aws_eip.eks_natgw_eip[0].public_ip}/32"
    ] : [
      "${chomp(data.http.my_public_ip.response_body)}/32"
    ]
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.eks_service_ipv4_cidr
    ip_family         = "ipv4"
  }
  
  # Control Plane Logging
  # enabled_cluster_log_types = [
  #   "api",
  #   "audit",
  #   "authenticator",
  #   "controllerManager",
  #   "scheduler"
  # ]

  depends_on = [
    aws_iam_role_policy_attachment.eks_control_plane_role_cluster,
    aws_iam_role_policy_attachment.eks_control_plane_role_vpc_resource
  ]

  tags = merge(
    {
      Name = var.eks_name
    },
    var.common_tags
  )
}

resource "local_sensitive_file" "kubeconfig" {
  content         = templatefile("kubeconfig.tpl", {
    cluster_name  = aws_eks_cluster.eks_cluster.name,
    clusterca     = aws_eks_cluster.eks_cluster.certificate_authority.0.data,
    endpoint      = aws_eks_cluster.eks_cluster.endpoint,
    token         = data.aws_eks_cluster_auth.eks_cluster.token,
  })
  filename        = pathexpand("~/.kube/${aws_eks_cluster.eks_cluster.name}")
  file_permission = "0644"
}

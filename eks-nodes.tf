resource "aws_security_group" "nodes_sg" {
  name = "node-${ var.eks_private_nodes ? "private" : "public" }-sg-${var.eks_name}" 
  vpc_id = aws_vpc.eks_vpc.id
  description = "EKS ${ var.eks_private_nodes ? "private" : "public" } nodes security group"

  tags = merge(
    {
      Name = "node-${ var.eks_private_nodes ? "private" : "public" }-sg-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_security_group_rule" "nodes_sg_eks_ingress_rule" {
  security_group_id        = aws_security_group.nodes_sg.id
  source_security_group_id = aws_security_group.eks_control_plane_sg.id
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
  description              = "EKS ${ var.eks_private_nodes ? "private" : "public" } nodes ingress rule - Allow EKS control plane"
}

resource "aws_security_group_rule" "nodes_sg_egress_rule" {
  security_group_id = aws_security_group.nodes_sg.id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
  description       = "EKS ${ var.eks_private_nodes ? "private" : "public" } nodes egress rule - All traffic"
}

resource "aws_security_group" "nodes_remote_access_sg" {
  name = "node-${ var.eks_private_nodes ? "private" : "public" }-remote-access-sg-${var.eks_name}" 
  vpc_id = aws_vpc.eks_vpc.id
  description = "EKS ${ var.eks_private_nodes ? "private" : "public" } nodes remote access security group"

  tags = merge(
    {
      Name = "node-${ var.eks_private_nodes ? "private" : "public" }-remote-access-sg-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_security_group_rule" "nodes_remote_access_sg_ingress_rule" {
  count = var.eks_private_nodes ? 1 : 0
  security_group_id = aws_security_group.nodes_remote_access_sg.id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = var.eks_private_nodes ? null : ["${chomp(data.http.my_public_ip.response_body)}/32"]
  source_security_group_id = var.eks_private_nodes ? aws_security_group.bastion_sg[0].id : null
  type              = "ingress"
  description       = "EKS ${ var.eks_private_nodes ? "private" : "public" } nodes ingress rule - Remote access"
}

resource "aws_security_group_rule" "nodes_remote_access_sg_egress_rule" {
  security_group_id = aws_security_group.nodes_remote_access_sg.id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
  description       = "EKS ${ var.eks_private_nodes ? "private" : "public" } nodes egress rule - Remote access"
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name

  node_group_name = "${ var.eks_private_nodes ? "private" : "public" }-node-group-${var.eks_name}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.eks_private_nodes ? aws_subnet.eks_private_subnet[*].id : aws_subnet.eks_public_subnet[*].id
  
  ami_type = "AL2_x86_64"  
  capacity_type = "ON_DEMAND"
  disk_size = 20
  instance_types = var.eks_nodes_ec2.instance_types

  remote_access {
    ec2_ssh_key               = aws_key_pair.eks_ssh_key.key_name
    source_security_group_ids = [
      aws_security_group.nodes_remote_access_sg.id
    ]
  }

  scaling_config {
    desired_size = var.eks_nodes_ec2.scaling_size
    min_size     = var.eks_nodes_ec2.scaling_min 
    max_size     = var.eks_nodes_ec2.scaling_max
  }

  labels = {
    "ingress/ready" = "true" # Used by Nginx Ingress Controller
  }

  update_config {
    max_unavailable = 1    
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_role_eks_worker,
    aws_iam_role_policy_attachment.eks_node_role_cni,
    aws_iam_role_policy_attachment.eks_node_role_container_registry
  ] 

  tags = merge(
    {
      Name = "${ var.eks_private_nodes ? "private" : "public" }-node-group-${var.eks_name}",
      "kubernetes.io/cluster/${var.eks_name}" = "owned"
    },
    var.common_tags
  )
}

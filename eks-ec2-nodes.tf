resource "aws_security_group" "nodes_sg" {
  for_each = {
    for node, conf in var.eks_nodes :
      node => conf if conf != null && node != "fargate"
  }
  name = "node-${ replace(each.key,"_","-") }-sg-${var.eks_name}" 
  vpc_id = aws_vpc.eks_vpc.id
  description = "EKS ${ replace(each.key,"_","-") } nodes security group"

  tags = merge(
    {
      Name = "node-${ replace(each.key,"_","-") }-sg-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_security_group_rule" "nodes_sg_eks_ingress_rule" {
  for_each = {
    for node, conf in var.eks_nodes :
      node => conf if conf != null && node != "fargate"
  }
  security_group_id        = aws_security_group.nodes_sg[each.key].id
  source_security_group_id = aws_security_group.eks_control_plane_sg.id
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
  description              = "EKS ${ replace(each.key,"_","-") } nodes ingress rule - Allow EKS control plane"
}

resource "aws_security_group_rule" "nodes_sg_egress_rule" {
  for_each = {
    for node, conf in var.eks_nodes :
      node => conf if conf != null && node != "fargate"
  }
  security_group_id = aws_security_group.nodes_sg[each.key].id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
  description       = "EKS ${ replace(each.key,"_","-") } nodes egress rule - All traffic"
}

resource "aws_security_group" "nodes_remote_access_sg" {
  for_each = {
    for node, conf in var.eks_nodes :
      node => conf if conf != null && node != "fargate"
  }
  name = "node-${ replace(each.key,"_","-") }-remote-access-sg-${var.eks_name}" 
  vpc_id = aws_vpc.eks_vpc.id
  description = "EKS ${ replace(each.key,"_","-") } nodes remote access security group"

  tags = merge(
    {
      Name = "node-${ replace(each.key,"_","-") }-remote-access-sg-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_security_group_rule" "nodes_remote_access_sg_ingress_rule" {
  for_each = {
    for node, conf in var.eks_nodes :
      node => conf if conf != null && node != "fargate"
  }
  security_group_id = aws_security_group.nodes_remote_access_sg[each.key].id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = each.key == "private_ec2" ? null : ["${chomp(data.http.my_public_ip.response_body)}/32"]
  source_security_group_id = each.key == "private_ec2" ? aws_security_group.bastion_sg[0].id : null
  type              = "ingress"
  description       = "EKS ${ replace(each.key,"_","-") } nodes ingress rule - Remote access"
}

resource "aws_security_group_rule" "nodes_remote_access_sg_egress_rule" {
  for_each = {
    for node, conf in var.eks_nodes :
      node => conf if conf != null && node != "fargate"
  }
  security_group_id = aws_security_group.nodes_remote_access_sg[each.key].id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
  description       = "EKS ${ replace(each.key,"_","-") } nodes egress rule - Remote access"
}

resource "aws_eks_node_group" "eks_node_group" {
  for_each = {
    for node, conf in var.eks_nodes :
      node => conf if conf != null && node != "fargate"
  }

  cluster_name    = aws_eks_cluster.eks_cluster.name

  node_group_name = "${ replace(each.key,"_","-") }-node-group-${var.eks_name}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = each.key == "private_ec2" ? aws_subnet.eks_private_subnet[*].id : aws_subnet.eks_public_subnet[*].id
  
  ami_type = "AL2_x86_64"  
  capacity_type = "ON_DEMAND"
  disk_size = 20
  instance_types = each.value.instance_types

  remote_access {
    ec2_ssh_key               = aws_key_pair.eks_ssh_key.key_name
    source_security_group_ids = [
      aws_security_group.nodes_remote_access_sg[each.key].id
    ]
  }

  scaling_config {
    desired_size = each.value.scaling_size
    min_size     = each.value.scaling_min 
    max_size     = each.value.scaling_max
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
      Name = "${ replace(each.key,"_","-") }-node-group-${var.eks_name}",
      "kubernetes.io/cluster/${var.eks_name}" = "owned"
    },
    var.common_tags
  )
}

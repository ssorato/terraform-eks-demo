output "private_subnet_internet_gw_ip" {
  description = "Private subnet internet gw ip"
  value = var.eks_nodes.private_ec2 != null ? aws_eip.eks_natgw_eip[0].public_ip : null
}

output "kubeconfig" {
  value = local_sensitive_file.kubeconfig.filename
}

output "eksreader1-arn" {
  value     = var.create_sample_users ? aws_iam_user.eksreader1[0].arn : null
  sensitive = true
}

output "eksreader1-credential" {
  value     = var.create_sample_users ? data.pgp_decrypt.eksreader1_login[0].plaintext : null
  sensitive = true
}

output "eksreader1-acess-key-id" {
  value     = var.create_sample_users ? aws_iam_access_key.eksreader1[0].id : null
  sensitive = true
}

output "eksreader1-acess-key-secret" {
  value     = var.create_sample_users ? data.pgp_decrypt.eksreader1_access_key[0].plaintext : null
  sensitive = true
}

output "eksadmin1-arn" {
  value     = var.create_sample_users ? aws_iam_user.eksadmin1[0].arn : null
  sensitive = true
}

output "eksadmin1-credential" {
  value     = var.create_sample_users ? data.pgp_decrypt.eksadmin1_login[0].plaintext : null
  sensitive = true
}

output "eksadmin1-acess-key-id" {
  value     = var.create_sample_users ? aws_iam_access_key.eksadmin1[0].id : null
  sensitive = true
}

output "eksadmin1-acess-key-secret" {
  value     = var.create_sample_users ? data.pgp_decrypt.eksadmin1_access_key[0].plaintext : null
  sensitive = true
}

output "bastion_public_ip" {
  value     = var.eks_nodes.private_ec2 != null ? aws_instance.bastion[0].public_ip : null
}

output "eks_api_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "nodes_sg" {
  value = values(aws_security_group.nodes_sg)[*].id
  description = "SG used in node group"
}

# output "nodes_sg_remote_access" {
#   value = values(aws_security_group.nodes_remote_access_sg)[*].id
#   description = "SG used in remote access node group"
# }

output "eks_control_plane_sg" {
  value = aws_security_group.eks_control_plane_sg.id
  description = "SG eks_control_plane_sg"
}

output "eks_cluster_sg" {
  value = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  description = "EKS SG id"
}
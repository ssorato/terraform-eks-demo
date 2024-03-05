output "private_subnet_internet_gw_ip" {
  description = "Private subnet internet gw ip"
  value = var.eks_private_nodes ? aws_eip.eks_natgw_eip[0].public_ip : null
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
  value     = var.eks_private_nodes ? aws_instance.bastion[0].public_ip : null
}

output "eks_api_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
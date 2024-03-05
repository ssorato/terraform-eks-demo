data "aws_caller_identity" "current" {}

data "http" "my_public_ip" {
  url = "http://ifconfig.me"
}

data "aws_availability_zones" "region_azones" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.id
}

data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

data "pgp_decrypt" "eksreader1_login" {
  count = var.create_sample_users ? 1 : 0
  private_key         = pgp_key.eksreader1[0].private_key
  ciphertext          = aws_iam_user_login_profile.eksreader1[0].encrypted_password
  ciphertext_encoding = "base64"
}

data "pgp_decrypt" "eksreader1_access_key" {
  count = var.create_sample_users ? 1 : 0
  private_key         = pgp_key.eksreader1[0].private_key
  ciphertext          = aws_iam_access_key.eksreader1[0].encrypted_secret
  ciphertext_encoding = "base64"
}

data "pgp_decrypt" "eksadmin1_login" {
  count = var.create_sample_users ? 1 : 0
  private_key         = pgp_key.eksadmin1[0].private_key
  ciphertext          = aws_iam_user_login_profile.eksadmin1[0].encrypted_password
  ciphertext_encoding = "base64"
}

data "pgp_decrypt" "eksadmin1_access_key" {
  count = var.create_sample_users ? 1 : 0
  private_key         = pgp_key.eksadmin1[0].private_key
  ciphertext          = aws_iam_access_key.eksadmin1[0].encrypted_secret
  ciphertext_encoding = "base64"
}

/*
data "aws_ami" "aws_image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al202*-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
*/
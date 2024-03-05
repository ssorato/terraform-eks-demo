resource "aws_key_pair" "eks_ssh_key" {

  key_name   = "ssh-key-${var.eks_name}"
  public_key = file(var.bastion_public_key_path)
  
  tags = merge(
    {
      Name = "ssh-key-${var.eks_name}"
    },
    var.common_tags
  )
}
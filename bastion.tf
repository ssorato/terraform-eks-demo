resource "aws_security_group" "bastion_sg" {
  count = var.eks_private_nodes ? 1 : 0

  name          = "bastion-sg-${var.eks_name}"
  vpc_id        = aws_vpc.eks_vpc.id
  description   = "The bastion security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
    description = "Grant ssh access from my public ip"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Grant access to the internet"
  }

  tags = merge(
    {
      Name = "bastion-sg-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_security_group_rule" "bastion_sg_ingress_self" {
  count = var.eks_private_nodes ? 1 : 0
  description              = "Bastion self ingress rule"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.bastion_sg[0].id
  source_security_group_id = aws_security_group.bastion_sg[0].id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_instance" "bastion" {
  count = var.eks_private_nodes ? 1 : 0

  ami                         = "ami-0e9107ed11be76fde"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.eks_public_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.bastion_sg[0].id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.eks_ssh_key.key_name

  tags = merge(
    {
      Name = "bastion-${var.eks_name}"
    },
    var.common_tags
  )
}

variable "aws_region" {
  type        = string
  description = "The AWS region"
  default     = "us-east-1"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags"
  default     = {
    created_by = "terraform-eks-demo-private"
    sandbox    = "devops"
  }
}

variable "eks_name" {
  type        = string
  description = "The EKS cluster name"
  default     = "tf-eks-demo"
  validation {
    condition     = !can(regex("\\s|_", var.eks_name))
    error_message = "The EKS cluster name cannot contains spaces and underlines" # just to keep Name tag more readable
  }
}

variable "eks_private_nodes" {
  type        = bool
  description = "Configure EKS with private subnet"
  default     = false
}

variable "k8s_version" {
  type        = string
  description = "The k8s version"
  default     = "1.29" # latest 1.29
}

variable "eks_service_ipv4_cidr" {
  type        = string
  description = "The CIDR block to assign Kubernetes pod and service IP addresses from"
  default     = "10.100.0.0/16"
  validation {
    condition     = can(cidrhost(var.eks_service_ipv4_cidr, 0))
    error_message = "The block must be a valid IPv4 CIDR."
  }
}

variable "eks_nodes_ec2" {
  type = object({
    instance_types  = list(string),
    scaling_min     = number
    scaling_max     = number
    scaling_size    = number
  })
  description = "The EKS EC2 node group size"
  default     = {
    instance_types  = ["t3a.medium"],
    scaling_min     = 1
    scaling_max     = 3
    scaling_size    = 2
  }
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC CIDR"
  default     = "172.16.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The VPC must be a valid IPv4 CIDR."
  }
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "The public subnet CIDR"
  default     = ["172.16.1.0/24","172.16.2.0/24"]
  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidr : can(cidrhost(cidr, 0))
    ])
    error_message = "The public subnet must be a valid IPv4 CIDR."
  }
}

variable "private_subnet_cidr" {
  type        = list(string)
  description = "The private subnet CIDR"
  default     = ["172.16.10.0/24","172.16.20.0/24"]
  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidr : can(cidrhost(cidr, 0))
    ])
    error_message = "The private subnet must be a valid IPv4 CIDR."
  }
}

variable "bastion_public_key_path" {
  type        = string
  description = "The bastion ssh public key path"
  default     = "~/.ssh/id_rsa.pub"
}

variable "bastion_private_key_path" {
  type        = string
  description = "The bastion ssh private key path"
  default     = "~/.ssh/id_rsa"
}

variable "eks_oidc_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

variable "create_sample_users" {
  type        = bool
  description = "Create sample users and group in the EKS"
  default     = false
  
}
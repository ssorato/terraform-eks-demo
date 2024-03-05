terraform {

  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.26.0"
    }
  
    tls = {
      source  = "tls"
      version = "~> 4.0.5"
    }

    pgp = {
      source = "ekristen/pgp"
      version = "~> 0.2.4"
    }

    helm = {
      source = "hashicorp/helm"
      version = "~> 2.12.1"
    }

    http = {
      source = "hashicorp/http"
      version = "~> 3.4.1"
    }
  }

  # backend "s3" {
  #   bucket = "<bucket name>"
  #   key    = "<tfstate filename>"
  #   region = "us-east-1"

  #   # For State Locking
  #   dynamodb_table = "<dynamodb table lock>"
  # }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
  }
}

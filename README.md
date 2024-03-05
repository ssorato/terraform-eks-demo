# Terraform EKS demo

Create an EKS using Terraform, incluinding sample users and groups.

## kubeconfig

Update kubeconfig file:

```bash
$ aws eks update-kubeconfig --region us-east-1 --name eks-tf-demo
```

## Credits

[Terraform on AWS EKS Kubernetes IaC SRE- 50 Real-World Demos](https://www.udemy.com/course/terraform-on-aws-eks-kubernetes-iac-sre-50-real-world-demos/)

[Matheus Fidelis GitHub - EKS with Istio](https://github.com/msfidelis/eks-with-istio)

[How to Add IAM User and IAM Role to AWS EKS Cluster?](https://antonputra.com/kubernetes/add-iam-user-and-iam-role-to-eks/)

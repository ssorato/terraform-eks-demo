#
# RBAC eks read-only
#
resource "kubernetes_cluster_role_v1" "eksreadonly_clusterrole" {
  count = var.create_sample_users ? 1 : 0
  metadata {
    name = "${var.eks_name}-eksreadonly-clusterrole"
  }

  rule {
    api_groups = [""] # These come under core APIs
    resources  = ["nodes", "namespaces", "pods", "events", "services"]
    verbs      = ["get", "list", "watch"]    
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "statefulsets", "replicasets"]
    verbs      = ["get", "list", "watch"]    
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch"]    
  }  
}

resource "kubernetes_cluster_role_binding_v1" "eksreadonly_clusterrolebinding" {
  count = var.create_sample_users ? 1 : 0
  metadata {
    name = "${var.eks_name}-eksreadonly-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.eksreadonly_clusterrole[0].metadata.0.name 
  }
  subject {
    kind      = "Group"
    name      = "${var.eks_name}-readonly-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

#
# RBAC eks admin
#
resource "kubernetes_cluster_role_v1" "eksadmin_clusterrole" {
  count = var.create_sample_users ? 1 : 0
  metadata {
    name = "${var.eks_name}-eksadmin-clusterrole"
  }

  rule {
    api_groups = [""] # These come under core APIs
    resources  = ["nodes", "namespaces", "pods", "events", "services"]
    verbs      = ["*"]    
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "statefulsets", "replicasets"]
    verbs      = ["*"]    
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["*"]    
  }  
}

resource "kubernetes_cluster_role_binding_v1" "eksadmin_clusterrolebinding" {
  count = var.create_sample_users ? 1 : 0
  metadata {
    name = "${var.eks_name}-eksadmin-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.eksadmin_clusterrole[0].metadata.0.name 
  }
  subject {
    kind      = "Group"
    name      = "${var.eks_name}-admin-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

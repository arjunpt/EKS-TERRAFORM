# 🚀 EKS Cluster Control Plane Setup using Terraform

## 📌 Objective

This document provides a comprehensive explanation of provisioning an **Amazon EKS Control Plane** using Terraform. It covers key configuration blocks including IAM, VPC integration, OpenID Connect, access control, and best practices for conditional resource creation.

---

## 📁 Prerequisites

Before proceeding with this Terraform configuration, ensure the following prerequisites are met:

- ✅ Terraform v1.0+ is installed
- ✅ AWS CLI is configured with programmatic access
- ✅ A VPC is already provisioned with public/private subnets
- ✅ An IAM role is available for EKS cluster management
- ✅ Security groups are defined for EKS API access
- ✅ You understand how OIDC works for IRSA (IAM Roles for Service Accounts)

---

## 🔁 Workflow Summary

1. Create the EKS cluster control plane
2. Configure access settings (IAM-based authentication)
3. Attach the cluster to specific VPC subnets and security groups
4. Enable OIDC provider for pod-level IAM access (IRSA)
5. Use conditional resource creation for flexible deployments

---

## ✅ Terraform Configuration Breakdown

### ✅ `aws_eks_cluster` – Creating the EKS Control Plane

```hcl
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  count    = var.is_eks_cluster_enabled == true ? 1 : 0
  role_arn = aws_iam_role.eks-cluster-role[count.index].arn
  version  = var.cluster_version

  access_config {
    authentication_mode                         = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  tags = {
    Environment = var.environment
    Name        = var.cluster_name
  }
}

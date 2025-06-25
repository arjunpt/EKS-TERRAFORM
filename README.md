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

```

🧠 Parameters:
name: Human-readable name for the EKS cluster (var.cluster_name).

count: Conditional creation of the cluster (creates it only if is_eks_cluster_enabled == true).

role_arn: IAM role with EKS service permissions.

version: EKS Kubernetes version (1.28, 1.29, etc.).

🔁 Workflow:
This sets up the control plane (managed by AWS). No EC2 instances run here—only control APIs.


### ✅ access_config


```hcl
access_config {
    authentication_mode = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }


```
🧠 Why:
authentication_mode = "CONFIG_MAP": Allows IAM-based access via aws-auth ConfigMap. There is AP
bootstrap_cluster_creator_admin_permissions = true: The creator gets full admin access automatically.


### ✅ ` vpc_config` 

```hcl
  vpc_config {
    subnet_ids              = [...]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

```
🧠 Why:
subnet_ids: Cluster needs networking to deploy workloads.

endpoint_private_access: Whether you can access cluster privately (inside VPC).

endpoint_public_access: Enables access from internet (like from laptop).

security_group_ids: Controls who can access EKS API endpoint (usually only admins or CI/CD).



### ✅ `aws_iam_openid_connect_provider`

```hcl
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_certificate.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks_certificate.url
}

```
✅ Concept:
Enables Kubernetes service accounts to assume IAM roles via OIDC → IAM Roles for Service Accounts (IRSA).

🧠 Why:
Secure way to give pods IAM permissions without attaching EC2 instance roles.



### ✅ `aws_eks_addon` 

```hcl
resource "aws_eks_addon" "eks_addons" {
  for_each      = { for idx, addon in var.addons : idx => addon }
  cluster_name  = aws_eks_cluster.eks[0].name
  addon_name    = each.value.name
  addon_version = each.value.version

  depends_on = [
    aws_eks_node_group.ondemand_node,
    aws_eks_node_group.spot_node
  ]
}


```
✅ Concept:
Manages managed add-ons like VPC CNI, CoreDNS, kube-proxy, etc.

🧠 Why:
Using Terraform to manage EKS add-ons ensures you are version-controlling your infra.

depends_on: Wait for worker nodes to be ready before applying add-ons.

### ✅ `aws_eks_node_group` - ondemand_node

```hcl
resource "aws_eks_node_group" "ondemand_node" {
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-on-demand-nodes"
  ...
  capacity_type   = "ON_DEMAND"
}

```
🔁 Workflow:
Creates managed EC2 node group using on-demand instances for predictable workloads.

🧠 Why:
desired_size, min_size, max_size: Auto Scaling config.

instance_types: Controls cost and performance.

capacity_type: On-demand = stable but expensive.

labels: Used in pod scheduling via node selectors or affinities.

update_config.max_unavailable: Controls how many nodes can go down during rolling update.



### ✅ `aws_eks_node_group ` – spot_node

```hcl
resource "aws_eks_node_group" "spot_node" {
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-spot-nodes"
  ...
  capacity_type   = "SPOT"
}
```
🔁 Workflow:
Creates a node group with Spot Instances—cheaper, but can be interrupted.

🧠 Why:
Best for batch jobs, stateless workloads, or cost savings.

disk_size: Attached volume size (default is 20GB, here it’s 50GB).

labels.lifecycle = "spot": Helps in workload scheduling via tolerations.




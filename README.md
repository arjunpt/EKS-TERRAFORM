Here’s a detailed explanation of the Terraform configuration you shared, broken down resource by resource, with a focus on:

✅ Concept

🔁 Workflow

🧠 Why each parameter is used

✅ aws_eks_cluster – Creating the EKS Control Plane
hcl
Copy
Edit
resource "aws_eks_cluster" "" {
  name     = var.cluster_name
  count    = var.is_eks_cluster_enabled == true ? 1 : 0
  role_arn = aws_iam_role.eks-cluster-role[count.index].arn
  version  = var.cluster_version
🧠 Parameters:
name: Human-readable name for the EKS cluster (var.cluster_name).

count: Conditional creation of the cluster (creates it only if is_eks_cluster_enabled == true).

role_arn: IAM role with EKS service permissions.

version: EKS Kubernetes version (1.28, 1.29, etc.).

🔁 Workflow:
This sets up the control plane (managed by AWS). No EC2 instances run here—only control APIs.

✅ access_config
hcl
Copy
Edit
  access_config {
    authentication_mode = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
🧠 Why:
authentication_mode = "CONFIG_MAP": Allows IAM-based access via aws-auth ConfigMap.

bootstrap_cluster_creator_admin_permissions = true: The creator gets full admin access automatically.

✅ vpc_config
hcl
Copy
Edit
  vpc_config {
    subnet_ids              = [...]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }
🧠 Why:
subnet_ids: Cluster needs networking to deploy workloads.

endpoint_private_access: Whether you can access cluster privately (inside VPC).

endpoint_public_access: Enables access from internet (like from laptop).

security_group_ids: Controls who can access EKS API endpoint (usually only admins or CI/CD).

✅ aws_iam_openid_connect_provider
hcl
Copy
Edit
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_certificate.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks_certificate.url
}
✅ Concept:
Enables Kubernetes service accounts to assume IAM roles via OIDC → IAM Roles for Service Accounts (IRSA).

🧠 Why:
Secure way to give pods IAM permissions without attaching EC2 instance roles.


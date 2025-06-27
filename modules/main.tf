resource "aws_eks_cluster" "eks" {
  name = var.cluster_name
  count = var.is_eks_cluster_enabled == true ? 1:0
  role_arn = aws_iam_role.eks_cluster_role[count.index].arn
  version  = var.cluster_version


  access_config {
    authentication_mode = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }



  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [var.eks_cluster_security_group_id]
  }

  tags = {
    Name = var.cluster_name
    Env  = var.env
  }
}



# OIDC Provider
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_certificate.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks_certificate.url
}


# AddOns for EKS Cluster
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



# NodeGroups
resource "aws_eks_node_group" "ondemand_node" {
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-on-demand-nodes"

  node_role_arn = aws_iam_role.eks_nodegroup_role[0].arn

  scaling_config {
    desired_size = var.desired_capacity_on_demand
    min_size     = var.min_capacity_on_demand
    max_size     = var.max_capacity_on_demand
  }

 subnet_ids = var.private_subnet_ids

  instance_types = var.ondemand_instance_types
  capacity_type  = "ON_DEMAND"
  labels = {
    type = "ondemand"
  }

  update_config {
    max_unavailable = 1
  }
  tags = {
    "Name" = "${var.cluster_name}-ondemand-nodes"
  }

  depends_on = [aws_eks_cluster.eks]
}

resource "aws_eks_node_group" "spot_node" {
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-spot-nodes"

  node_role_arn = aws_iam_role.eks_nodegroup_role[0].arn

  scaling_config {
    desired_size = var.desired_capacity_spot
    min_size     = var.min_capacity_spot
    max_size     = var.max_capacity_spot
  }


  subnet_ids = var.private_subnet_ids

  instance_types = var.spot_instance_types
  capacity_type  = "SPOT"

  update_config {
    max_unavailable = 1
  }
  tags = {
    "Name" = "${var.cluster_name}-spot-nodes"
  }
  labels = {
    type      = "spot"
    lifecycle = "spot"
  }
  disk_size = 50

  depends_on = [aws_eks_cluster.eks]
}

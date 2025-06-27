
module "eks" {
    source = "../Modules/eks"
    cluster_name          = var.cluster_name
    is_eks_role_enabled           = true
    is_eks_nodegroup_role_enabled = true
    ondemand_instance_types       = var.ondemand_instance_types
    spot_instance_types           = var.spot_instance_types
    desired_capacity_on_demand    = var.desired_capacity_on_demand
    min_capacity_on_demand        = var.min_capacity_on_demand
    max_capacity_on_demand        = var.max_capacity_on_demand
    desired_capacity_spot         = var.desired_capacity_spot
    min_capacity_spot             = var.min_capacity_spot
    max_capacity_spot             = var.max_capacity_spot
    is_eks_cluster_enabled        = var.is_eks_cluster_enabled
    cluster_version               = var.cluster_version
    endpoint_private_access       = var.endpoint_private_access
    endpoint_public_access        = var.endpoint_public_access
    addons = var.addons
    vpc_id                        = module.vpc.vpc_id
    private_subnet_ids            = module.vpc.private_subnet_ids
    eks_cluster_security_group_id = module.vpc.eks_cluster_security_group_id
    env                   = var.env

  
}

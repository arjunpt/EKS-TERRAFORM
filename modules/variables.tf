# Cluster Configuration
variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
}

variable "is_eks_cluster_enabled" {
  description = "Enable or disable EKS cluster provisioning"
  type        = bool
  default     = true
}

# Access Control
variable "endpoint_private_access" {
  description = "Whether the EKS private endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the EKS public endpoint is enabled"
  type        = bool
  default     = false
}

# EKS Addons
variable "addons" {
  description = "Map of EKS addons with name and version"
  type = list(object({
    name    = string
    version = string
  }))
  default = []
}


# On-Demand Node Group Config
variable "ondemand_instance_types" {
  description = "List of EC2 instance types for On-Demand nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_capacity_on_demand" {
  description = "Desired number of On-Demand nodes"
  type        = number
  default     = 2
}

variable "min_capacity_on_demand" {
  description = "Minimum number of On-Demand nodes"
  type        = number
  default     = 1
}

variable "max_capacity_on_demand" {
  description = "Maximum number of On-Demand nodes"
  type        = number
  default     = 3
}

# Spot Node Group Config
variable "spot_instance_types" {
  description = "List of EC2 instance types for Spot nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_capacity_spot" {
  description = "Desired number of Spot nodes"
  type        = number
  default     = 2
}

variable "min_capacity_spot" {
  description = "Minimum number of Spot nodes"
  type        = number
  default     = 1
}

variable "max_capacity_spot" {
  description = "Maximum number of Spot nodes"
  type        = number
  default     = 4
}

# Tags
variable "env" {
  description = "Environment tag for the resources (e.g., dev, staging, prod)"
  type        = string
}

# Optional - Add this if using security group variable externally
variable "eks_cluster_sg" {
  description = "Security group ID for the EKS cluster"
  type        = string
  default     = ""
}



###############IAM ROLE ##########
# Enable/Disable IAM Role for EKS Cluster
variable "is_eks_role_enabled" {
  description = "Flag to create IAM role for EKS cluster"
  type        = bool
  default     = true
}

# Enable/Disable IAM Role for EKS Node Group
variable "is_eks_nodegroup_role_enabled" {
  description = "Flag to create IAM role for EKS node group"
  type        = bool
  default     = true
}


###for output
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}
variable "eks_cluster_security_group_id" {
  description = "Security group ID for EKS cluster"
  type        = string
}

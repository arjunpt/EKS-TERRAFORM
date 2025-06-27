

is_eks_cluster_enabled = true
cluster_version         = "1.32"
cluster_name               = "eks-cluster"
endpoint_private_access    = true #Access from Within VPC (If Keeping Private Only) , we have to spin one ec2 and need to access from there
endpoint_public_access     = true #if we mark false we cant access from outside will te time out
ondemand_instance_types    = ["t3.medium"]
spot_instance_types        = ["t3.micro", "t3.small", "t3a.micro"]
desired_capacity_on_demand = "1"
min_capacity_on_demand     = "1"
max_capacity_on_demand     = "1"
desired_capacity_spot      = "1"
min_capacity_spot          = "1"
max_capacity_spot          = "1"
addons = [
  {
    name    = "vpc-cni",
    version = "v1.19.6-eksbuild.1"
  },
  {
    name    = "coredns"
    version = "v1.11.4-eksbuild.14"
  },
  {
    name    = "kube-proxy"
    version = "v1.32.5-eksbuild.2"
  },
  {
    name    = "aws-ebs-csi-driver"
    version = "v1.45.0-eksbuild.2"
  }
  # Add more addons as needed
]

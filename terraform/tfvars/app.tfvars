name = "app"

vpc_cidr = "172.17.32.0/19"
azs = ["eu-west-1a","eu-west-1b","eu-west-1c"]
public_subnets = ["172.17.32.0/22","172.17.36.0/22","172.17.40.0/22"]
private_subnets = ["172.17.48.0/22","172.17.52.0/22","172.17.56.0/22"]

worker_ami_name_filter = "amazon-eks-node-1.27-v20230816"
eks_addon_version_kube_proxy = "v1.27.1-eksbuild.1"
eks_addon_version_core_dns = "v1.10.1-eksbuild.2"
eks_addon_version_vpc_cni = "v1.13.4-eksbuild.1"
ondemand_instance_type = "m6a.xlarge"
ondemand_desired_size = "1"
ondemand_max_size = "1"
spot_instance_types = ["t3a.large","t3.large"]
spot_desired_size = "1"
spot_max_size  = "5"
spot_min_size  = "0"

cluster_version = "1.27"
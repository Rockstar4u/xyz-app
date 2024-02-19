# required
variable "target_account_id" {
}

variable "backend_config_bucket" {
}

variable "backend_config_bucket_region" {
}

variable "backend_config_tfstate_file_key" {
}

variable "backend_config_role_arn" {
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list
}

# optional
variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = true
}

variable "eks_instance_type" {
  description = "Instance type to be used to create EKS cluster"
  type        = string
  default     = "t3.large"
}

variable "eks_asg_desired_capacity" {
  description = "Number of EC2 Instances within EKS ASG"
  type        = string
  default     = "2"
}

variable "eks_asg_max_size" {
  description = "Max number of EC2 Instances within EKS ASG"
  type        = string
  default     = "5"
}

variable "spot_instance_types" {
  description = "Spot instance type"
  type        = list
  default     = ["t3.large"]
}

variable "spot_desired_size" {
  description = "Number of spot Instances within EKS ASG"
  type        = string
  default     = "1"
}

variable "spot_max_size" {
  description = "Max number of spot EC2 Instances within EKS ASG"
  type        = string
  default     = "10"
}

variable "ondemand_instance_type" {
  description = "On Demand Instance type"
  type        = string
  default     = "t3.large"
}

variable "ondemand_desired_size" {
  description = "Number of ondemand Instances within EKS ASG"
  type        = string
  default     = "1"
}

variable "ondemand_max_size" {
  description = "Max number of ondemand Instances within EKS ASG"
  type        = string
  default     = "2"
}

variable "secondary_ondemand_instance_type" {
  description = "Secondary On Demand Instance type"
  type        = string
  default     = "t3.large"
}

variable "secondary_ondemand_desired_size" {
  description = "Number of secondary ondemand Instances within EKS ASG"
  type        = string
  default     = "1"
}

variable "secondary_ondemand_max_size" {
  description = "Max number of secondary ondemand Instances within EKS ASG"
  type        = string
  default     = "2"
}

variable "secondary_ondemand_min_size" {
  description = "Min number of secondary ondemand Instances within EKS ASG"
  type        = string
  default     = "1"
}

variable "spot_min_size" {
  description = "Min number of Spot Instances within EKS ASG"
  type        = string
  default     = "0"
}

variable "key_name" {
  description = "The key name that should be used for the instance"
  type        = string
  default     = ""
}

# optional
variable "region" {
  default = "eu-west-1"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  default     = "1.21"
}


variable "worker_ami_name_filter" {
  description = "EKS Worker ami name"
}

variable "eks_addon_version_kube_proxy" {
  type        = string
  description = "Kube proxy managed EKS addon version."
}

variable "eks_addon_version_core_dns" {
  type        = string
  description = "Core DNS managed EKS addon version."
}

variable "eks_addon_version_vpc_cni" {
  type        = string
  description = "VPC CNI managed EKS addon version."
}

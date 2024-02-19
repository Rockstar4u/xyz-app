module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "17.24.0"
  cluster_name                                 = var.name
  subnets                                      = module.vpc.private_subnets
  vpc_id                                       = module.vpc.vpc_id
  cluster_version                              = var.cluster_version
  worker_ami_name_filter                       = var.worker_ami_name_filter
  kubeconfig_aws_authenticator_additional_args = ["-r", "arn:aws:iam::${var.target_account_id}:role/terraform"]

  worker_groups_launch_template = [
    {
      name                      = "worker-group-spot-1"
      override_instance_types   = var.spot_instance_types
      spot_allocation_strategy  = "lowest-price"
      asg_max_size              = var.spot_max_size
      asg_min_size              = var.spot_min_size
      asg_desired_capacity      = var.spot_desired_size
      autoscaling_enabled       = var.name == "qa" ? true : false
      root_volume_type          = "gp2"
      subnets                   = module.vpc.private_subnets
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "node.kubernetes.io/lifecycle"
          "propagate_at_launch" = "false"
          "value"               = "spot"
        },
      ]
    },
  ]

  worker_groups = [
    {
      instance_type             = var.ondemand_instance_type
      asg_desired_capacity      = var.ondemand_desired_size
      asg_max_size              = var.ondemand_max_size
      key_name                  = var.key_name
      root_volume_type          = "gp2"
      kubelet_extra_args        = "--node-labels=application-type=statefulset"
      subnets                   = [module.vpc.private_subnets[1]]
      tags = [
        {
          "key"                 = "node.kubernetes.io/lifecycle"
          "propagate_at_launch" = "false"
          "value"               = "ondemand"
        },
        {
          "key"                 = "application-type"
          "propagate_at_launch" = "false"
          "value"               = "statefulset"
        },
      ]
    }
  ]
  map_accounts = [var.target_account_id]
  enable_irsa = true
  write_kubeconfig = false
  manage_aws_auth=true

  map_roles = [
    {
      rolearn = format("arn:aws:iam::%s:role/admin", var.target_account_id)
      username = format("%s-admin", var.name)
      groups    = ["system:masters"]
    },
    {
      rolearn = format("arn:aws:iam::%s:role/terraform", var.target_account_id)
      username = format("%s-user", var.name)
      groups    = ["system:masters"]
    }
  ]

}

resource "local_file" "kubeconfig" {
  content  = module.eks.kubeconfig
  filename = ".kube_config.yaml"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "kube-proxy"
  addon_version     = var.eks_addon_version_kube_proxy
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "core_dns" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "coredns"
  addon_version     = var.eks_addon_version_core_dns
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = module.eks.cluster_id
  addon_name   = "vpc-cni"
  addon_version = var.eks_addon_version_vpc_cni
  resolve_conflicts = "OVERWRITE"

  tags = {
    Name = "vpc-cni-addon"
  }
}

resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMTa3U8bz+IL4JAGlkeQPf62r2T5ViKpCo+GvOZ8u6KITrHT/nnpd0sbGi0pMTK71vpOk4g0PTxxuqXkXxbEbaL9mjvg14seZVhGWuNGq4sOrYd6dtFeUGIJ7ETgzIXx2ySkVwIQ4mLbqQfiLBg/wxtssJLLNfAcQj1If+wmznyMK28+KTb7ikHq13XRJuTWjgK64GcG2+LcSaGV3acdUQEI+8BMF/qgqrAMjY0WqoTWQrj2AUqwH5uAK9ndl2ltgCh9ajTrpaK31RRjMPJYjAy0eBANrmSmbU7hAf8GR6qdEaFM879VPr0OnfFfz88XrzZzZ48zqFltmCRfTDj7BN7elhuWPFVDsooUUnWB8HJAWuJCUDW62CsvR0RarWfgMww2YoY1po+YhDOZPrRMiupM3I2r3A4lo1u8OT/k3LqdogNZ8t3mEZi8QuURAVYe8Fc1PSLqfHW55R7rwYgbiig7o2SxuLga50lJM0gC1hPDi5QW2p0NcuQQ1OknafjPc= azure@DESKTOP-OILEMS6"
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.31" # later we upgrade 1.32
  create_node_security_group = false
  create_cluster_security_group = false
  cluster_security_group_id = local.eks_control_plane_sg_id
  node_security_group_id = local.eks_node_sg_id

  #bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server = {}
  }

  # Optional
  cluster_endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = ["m5.xlarge"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 10
      desired_size = 2
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
        Name = local.name
    }
  )
}
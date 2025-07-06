module "mysql_sg" {
  source = "git::https://github.com/ramki2537/terraform-aws-securitygroup.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "mysql"
  sg_description = "Created form MYSQL instances in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}


module "bastion_sg" {
  source = "git::https://github.com/ramki2537/terraform-aws-securitygroup.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "bastion"
  sg_description = "Created form bastion instances in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

# Ports 22, 443, 1194, 943  --> VPN ports
module "vpn_sg" {
  source = "git::https://github.com/ramki2537/terraform-aws-securitygroup.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "vpn"
  sg_description = "Created form vpn instances in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

module "alb_ingress_sg" {
  source = "git::https://github.com/ramki2537/terraform-aws-securitygroup.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "app-alb"
  sg_description = "Created for backend ALB in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

module "eks_control_plane_sg" {
  source = "git::https://github.com/ramki2537/terraform-aws-securitygroup.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "eks_control_plane"
  sg_description = "Created for backend ALB in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

module "eks_node_sg" {
  source = "git::https://github.com/ramki2537/terraform-aws-securitygroup.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "eks_node_sg"
  sg_description = "Created for backend ALB in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

resource "aws_security_group_rule" "eks_cotrol_plane_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_node_sg.sg_id
  security_group_id = module.eks_control_plane_sg.sg_id
}

resource "aws_security_group_rule" "eks_node_eks_control_plane" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_control_plane_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "node_alb_ingress" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "-1"
  source_security_group_id = module.alb_ingress_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "node_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = ["10.0.0.0/16"] # our private IP address range
  security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "node_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

# APP ALB accepting traffic from bastion
resource "aws_security_group_rule" "app_ingress_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.alb_ingress_sg.sg_id
}

resource "aws_security_group_rule" "app_ingress_bastion_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.alb_ingress_sg.sg_id
}


# JDOPS-32, bastion host should be accessed from office network
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.sg_id
}

#mysql accepting bastion
resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "mysql_eks_node" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.eks_node_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.eks_control_plane_sg.sg_id
}
module "vpc" {
  source        = "./modules/vpc"
  project_name  = var.project_name
  vpc_cidr      = var.vpc_cidr
  public_cidr_1 = var.public_cidr_1
  public_cidr_2 = var.public_cidr_2
  avail_zone_1  = var.avail_zone_1
  avail_zone_2  = var.avail_zone_2
}

module "security_group" {
  source       = "./modules/security-group"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  my_ip        = var.my_ip
}

module "alb" {
  source                = "./modules/alb"
  project_name          = var.project_name
  alb_security_group_id = module.security_group.alb_security_group_id
  public_subnet_1_id    = module.vpc.public_subnet_1_id
  public_subnet_2_id    = module.vpc.public_subnet_2_id
  vpc_id                = module.vpc.vpc_id
  ec2_instance_id       = module.ec2.instance_id
  acm_certificate_arn   = var.acm_certificate_arn
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "ec2" {
  source                = "./modules/ec2"
  instance_type         = var.instance_type
  public_subnet_1_id    = module.vpc.public_subnet_1_id
  ec2_security_group_id = module.security_group.ec2_security_group_id
  instance_profile_name = module.iam.instance_profile_name
  project_name          = var.project_name
  public_key_location   = var.public_key_location
  key_name              = var.key_name
}
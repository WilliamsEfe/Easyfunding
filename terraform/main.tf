provider "aws" {
  region = var.aws_region
}

module "rds" {
  source = "./modules/rds"
  db_users = var.db_users
  aws_region = var.aws_region
  account_id = var.account_id
  db_password = var.db_password
  ec2_public_dns = module.ec2.ec2_public_dns
}

module "ec2" {
  source   = "./modules/ec2"
  allow_sg = module.rds.rds_sg_id
  aws_region = var.aws_region
}


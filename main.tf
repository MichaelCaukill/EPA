provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "vpc" {
  source = "./terraform/vpc"

  aws_availability_a = "eu-west-2a"
  aws_availability_b = "eu-west-2b"
  open_internet       = var.open_internet
}

module "ec2" {
  source = "./terraform/ec2"

  vpc_id_ec2      = module.vpc.vpc_id
  subnet_id_ec2   = module.vpc.subnet_id_a
  ami_uk          = "ami-01c0ed0b087735750" # Ubuntu 20.04 in eu-west-2
  type            = "t2.micro"
  open_internet   = var.open_internet
  public_key_path = var.public_key_path
}
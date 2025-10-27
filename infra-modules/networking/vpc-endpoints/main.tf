
module "vpc-endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "4.0.1"
  vpc_id = var.vpc_id
  endpoints = var.endpoints
  security_group_ids = []
  subnet_ids = var.subnet_ids
  timeouts = {}
}
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.1.0, <6.0.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }

  source = "./modules/setup"
}

inputs = {
  # my betting company
  name_prefix      = "mbc"
  application_id   = "APM1234567"
  application_name = "mbc"
  team             = "mbc"
  aws_account_id   = "975050004152"
  account_type     = "nonprod"
  aws_region       = "us-east-1"
  aws_region_cd    = "use1"
}
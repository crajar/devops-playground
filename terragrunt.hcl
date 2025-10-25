# terragrunt.hcl

terraform {
  source = "."
}

inputs = {
  aws_region = "us-east-1"
}

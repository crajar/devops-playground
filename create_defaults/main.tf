terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  terraform_state_s3_bucket = "${var.env}-state-s3-bucket-for-team-bfs"
  terraform_lock_dynamodb_table = "${var.env}-lock-dynamodb-table-for-team-bfs"
}

provider "aws" {
  region = var.region
}

# --- Create the Spoke VPC ---
resource "aws_vpc" "spoke" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.env}-spoke-vpc"
    Environment = var.env
  }
}

# --- Create public subnet ---
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.spoke.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 0)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.env}-public-a"
  }
}

# --- Create private subnet ---
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 1)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.env}-private-a"
  }
}

# --- Internet Gateway (for public subnet) ---
resource "aws_internet_gateway" "spoke_igw" {
  vpc_id = aws_vpc.spoke.id

  tags = {
    Name = "${var.env}-igw"
  }
}

# --- Public route table ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.spoke.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.spoke_igw.id
  }

  tags = {
    Name = "${var.env}-public-rt"
  }
}

# --- Associate public subnet with route table ---
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.terraform_state_s3_bucket

  tags = {
    Name        = "${var.env}-terraform-state"
    Environment = var.env
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = local.terraform_lock_dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${var.env}-terraform-lock"
    Environment = var.env
  }
}


# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}


# --- Data source for AZs ---
data "aws_availability_zones" "available" {}

############################################
# PROVIDER CONFIGURATION
############################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-1"
}
module "setup" {
  source = "./modules/setup"
  # my betting company
  name_prefix      = "mbc"
  application_id   = "APM1234567"
  application_name = "mbc"
  created_by_email = "mydummyemail@dummy.com"
  team             = "mbc"
#  aws_account_id   = "975050004152"
#  account_type     = "nonprod"
  aws_region       = "us-east-1"
  aws_region_cd    = "use1"
  allowed_origins = "api.my-local-route53-zone-name"
  core_datadog_agent_host = "localhost"
  core_datadog_logs_injection_enabled = "true"
  core_datadog_profiling_enabled = "true"
  core_datadog_runtime_metrics_enabled = "true"
  core_datadog_trace_enabled = "true"
  core_datadog_trace_sample_rate = "1.0"
  core_datadog_version = "1.0.0"
  db_host = "localhost"
  db_port = "5432"
  db_secret_arn = "db_secret_arn"
  enable_datadog_agent = true
  environment = "dev"
  image_name = "992382468850.dkr.ecr.us-east-1.amazonaws.com/nestjs-sample"
  image_tag = "latest"
  vpc_id = aws_vpc.main.id
  private_subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  create_ecr_vpc_link = true

}


############################################
# VPC
############################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet A
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "public-subnet-a"
  }
}

# Private Subnet A
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-a"
  }
}

# Private Subnet B (new)
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-b"
  }
}

############################################
# INTERNET GATEWAY + ROUTE TABLES
############################################
# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

# Associate public subnet with route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

############################################
# SECURITY GROUPS
############################################
# Allow inbound SSH, HTTP, and Postgres
resource "aws_security_group" "main_sg" {
  name        = "main-sg"
  description = "Allow SSH, HTTP, and Postgres"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main-sg"
  }
}

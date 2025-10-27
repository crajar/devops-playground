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



############################################
# IAM Role for ECS Task Execution
############################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

############################################
# ECS Task Definition
############################################
resource "aws_ecs_task_definition" "nestjs-sample" {
  family                   = "nestjs-sample-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"    # 0.25 vCPU
  memory                   = "1024"    # 0.5 GB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = var.ecs_task_container_definitions
}


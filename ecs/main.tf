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
# ECS Cluster
############################################
resource "aws_ecs_cluster" "main" {
  name = "gps-ecs-cluster"
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
resource "aws_ecs_task_definition" "gps" {
  family                   = "gps-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"    # 0.25 vCPU
  memory                   = "512"    # 0.5 GB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "gps-container"
      image     = "951296734763.dkr.ecr.us-east-1.amazonaws.com/gps:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

############################################
# ECS Service
############################################
resource "aws_ecs_service" "gps" {
  name            = "gps-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.gps.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
#    subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]  # Replace with your public subnets
    subnets         = ["subnet-0c0cd09a0e35a7191"]  # Replace with your public subnets
#    security_groups = [aws_security_group.main_sg.id]
    security_groups = ["sg-077c9bdd714942de2"]
    assign_public_ip = true
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_attach]
}

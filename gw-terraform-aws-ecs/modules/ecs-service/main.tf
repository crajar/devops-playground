terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.1.0, <6.0.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

output "tcd" {
  value = var.ecs_task_container_definitions
}
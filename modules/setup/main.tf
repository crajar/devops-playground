locals {
  environment_variables = {
    SERVICE_NAME               = local.api_container_name
    PORT                       = tostring(local.http_port)
    ENVIRONMENT                = var.environment
    AWS_REGION                 = var.aws_region
    DATABASE_HOST              = var.db_host
    DATABASE_PORT              = var.db_port
    DATABASE_SECRET_ARN        = var.db_secret_arn
    ALLOWED_ORIGINS            = var.allowed_origins
    DD_AGENT_HOST              = var.core_datadog_agent_host
    DD_SERVICE                 = local.api_container_name
    DD_ENV                     = var.environment
    DD_VERSION                 = var.core_datadog_version
    DD_TRACE_ENABLED           = var.core_datadog_trace_enabled
    DD_RUNTIME_METRICS_ENABLED = var.core_datadog_runtime_metrics_enabled
    DD_LOGS_INJECTION          = var.core_datadog_logs_injection_enabled
    DD_PROFILING_ENABLED       = var.core_datadog_profiling_enabled
    DD_TRACE_SAMPLE_RATE       = var.core_datadog_trace_sample_rate
  }
  secret_arns = tomap({
  for key, value in local.environment_variables :
  key => value if endswith(key, "SECRET_ARN")
  })
}

module "ecs" {
  source                        = "../../blueprint-ecs/terraform"
  service_name                  = local.api_container_name
  aws_region                    = var.aws_region
  aws_region_cd                 = var.aws_region_cd
  cloudwatch_log_group          = local.cloudwatch_log_group
  cloudwatch_logs_aws_region    = var.aws_region
  cloudwatch_logs_stream_prefix = local.cloudwatch_logs_stream_prefix
  enable_datadog_agent          = var.enable_datadog_agent
  environment                   = var.environment
  launch_type                   = "FARGATE"
  name_prefix                   = var.name_prefix
  resource_slug                 = "spoke"
  secrets                       = {}
  advanced_container_definition = [
    {
      "name" : local.api_container_name,
      "image" : "${var.image_name}:${var.image_tag}"
      "cpu" : 256,
      "memory" : 512,
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : local.cloudwatch_log_group,
          "awslogs-region" : var.aws_region,
          "awslogs-stream-prefix" : local.cloudwatch_logs_stream_prefix
        }
      },
      "portMappings" : [
        {
          "containerPort" : local.http_port,
          "hostPort" : local.http_port,
          "protocol" : "tcp",
          "appProtocol" : "http2"
        }
      ],
      "environment" : [
      for k, v in local.environment_variables : {
        "name" : k,
        "value" : v
      }
      ],
      "healthCheck" : {
        "command" : [
          "CMD-SHELL",
          "curl -s http://localhost:8080/health | grep -o '\"status\": *\"[^\"]*\"' | head  -1 | cut -d':' -f2 | grep -q '\"ok\"' || exit 1"
        ],
        "interval" : 40,
        "timeout" : 30,
        "retries" : 3,
        "startPeriod" : 90
      },
      "secrets" : []
    }
  ]
}

module "endpoint_private_link" {
  count = var.create_ecr_vpc_link ? 1 : 0

  source = "../../infra-modules/networking/vpc-endpoints"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  endpoints = {
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
    }
  }
}

resource "aws_security_group" "allow_traffic_from_ecs_service" {
  description = "Allow pulling ${var.environment} ECS Service Docker images from the ECR"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_endpoint_security_group_association" "ecr_dkr" {
  count             = var.create_ecr_vpc_link ? 1 : 0
  security_group_id = aws_security_group.allow_traffic_from_ecs_service.id
  vpc_endpoint_id   = module.endpoint_private_link[0].endpoints["ecr_dkr"].id
}

data "aws_vpc_endpoint" "existing_ecr_dkr" {
  count = var.create_ecr_vpc_link ? 0 : 1

  vpc_id = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.ecr.dkr"
}

resource "aws_vpc_endpoint_security_group_association" "existing_ecr_dkr" {
  count             = var.create_ecr_vpc_link ? 0 : 1
  security_group_id = aws_security_group.allow_traffic_from_ecs_service.id
  vpc_endpoint_id   = data.aws_vpc_endpoint.existing_ecr_dkr[0].id
}

resource "aws_vpc_endpoint_security_group_association" "ecr_api" {
  count             = var.create_ecr_vpc_link ? 1 : 0
  vpc_endpoint_id   = module.endpoint_private_link[0].endpoints["ecr_api"].id
  security_group_id = aws_security_group.allow_traffic_from_ecs_service.id
}

data "aws_vpc_endpoint" "existing_ecr_api" {
  count = var.create_ecr_vpc_link ? 0 : 1

  vpc_id = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.ecr.api"
}

resource "aws_vpc_endpoint_security_group_association" "existing_ecr_api" {
  count = var.create_ecr_vpc_link ? 0 : 1
  vpc_endpoint_id = data.aws_vpc_endpoint.existing_ecr_api[0].id
  security_group_id = aws_security_group.allow_traffic_from_ecs_service.id
}

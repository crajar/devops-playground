locals {
  use_simple_container_definition = length(coalesce(var.advanced_container_definition, [])) == 0 ? true : false
  ecs_task_container_definition_vars = {
    container_definition_json = ((var.enable_datadog_agent && var.launch_type == "FARGATE")
    ? jsonencode(local.merged_container_definition) : local.unmerged_container_definition)
  }

  advanced_container_definition = !local.use_simple_container_definition ? var.advanced_container_definition : null

  merged_container_definition = (var.enable_datadog_agent
    ? local.use_simple_container_definition
    ? concat(local.simple_container_definition_vars, local.datadog_agent_fargate_container_definition)
    : concat(local.advanced_container_definition, local.datadog_agent_fargate_container_definition)
  : null)

  unmerged_container_definition = (local.use_simple_container_definition
    ? jsonencode(local.simple_container_definition_vars)
  : jsonencode(local.advanced_container_definition))

  simple_container_definition_vars = local.use_simple_container_definition ? [
    for container in var.containers :
    {
      "name" : container.name,
      "image" : container.image,
      "cpu" : container.cpu,
      "memory" : container.memory,
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : local.cloudwatch_log_group,
          "awslogs-region" : local.cloudwatch_logs_aws_region,
          "awslogs-stream-prefix" : local.cloudwatch_logs_stream_prefix
        }
      },
      "portMappings" : [{
        "containerPort" : container.http_port,
        "hostPort" : container.http_port,
        "protocol" : "tcp",
        "appProtocol" : "http2"
      }],
      "secrets" : length(var.secrets) > 0 ? [for key, value in var.secrets :
        {
          "name" : key,
          "valueFrom" : (key == "DATABASE_PASSWORD" ? "${value}:password::" : value)
        }
      ] : []
      "environment" : [for key, value in merge(local.environment, container.env_vars) :
        { "name" : key, "value" : value }
      ]
    }
  ] : null

  datadog_agent_fargate_container_definition = (var.enable_datadog_agent ?
    tolist([{
      "name" : "datadog-agent",
      "image" : local.datadog_agent_ecr_image,
      "cpu" : local.datadog_agent_cpu,
      "memory" : local.datadog_agent_memory,
      "environment" : [
        { name : "DD_API_KEY", value : "DD_API_KEY" },
        { name : "ECS_FARGATE", value : "true" }
      ]
    }])
  : null)
}
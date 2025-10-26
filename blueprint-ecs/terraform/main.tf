module "ecs-service" {
  source = "../../infra-modules/compute/ecs/ecs-service"
  advanced_container_definition = (var.advanced_container_definition != null
          ? var.advanced_container_definition : var.advanced_container_definition_file_path != null
          ? jsondecode(file(var.advanced_container_definition_file_path)) : null)
  aws_region = var.aws_region
  aws_region_cd = var.aws_region_cd
  cloudwatch_log_group = var.cloudwatch_log_group
  cloudwatch_logs_aws_region = var.cloudwatch_logs_aws_region
  cloudwatch_logs_stream_prefix = var.cloudwatch_logs_stream_prefix
  enable_datadog_agent = true
  environment = var.environment
  launch_type = var.launch_type
  name_prefix = var.name_prefix
  resource_slug = var.resource_slug
  service_name = var.service_name
  secrets = var.secrets
}

output "tcd"{
  value = module.ecs-service.tcd
}
module "ecs_service" {
  source = "../gw-terraform-aws-ecs/modules"
  ecs_task_container_definitions = templatefile("${path.module}/containers/container-definition.json", local.ecs_task_container_definition_vars)
}

module "cloudwatch_logs" {
  source = "../infra-modules/cloudwatch_log_group"
  count = var.cloudwatch_log_group == null ? 1 : 0
  log_group_name = "${local.constructed_service_name}-log-group"
}
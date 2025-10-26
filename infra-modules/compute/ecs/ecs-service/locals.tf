locals {
  _aws_region_tokens            = split("-", var.aws_region)
  aws_region_cd                 = "${local._aws_region_tokens[0]}${substr(local._aws_region_tokens[1], 0, 1)}${substr(local._aws_region_tokens[2], 0, 1)}"
  constructed_service_name      = "${var.name_prefix}-${var.environment}-${local.aws_region_cd}-${var.service_name}${local.resource_slug}"
  cloudwatch_log_group          = var.cloudwatch_log_group != null ? var.cloudwatch_log_group : module.cloudwatch_logs[0].log_group_name
  cloudwatch_logs_aws_region    = var.cloudwatch_logs_aws_region == "" ? var.aws_region : var.cloudwatch_logs_aws_region
  cloudwatch_logs_stream_prefix = var.cloudwatch_logs_stream_prefix == "" ? var.cloudwatch_logs_stream_prefix : "${local.constructed_service_name}-stream"
  resource_slug                 = (var.resource_slug != null && var.resource_slug != "") ? format("-%s", var.resource_slug) : ""
  environment = {
    AWS_REGION = var.aws_region,
    ENVIRONMENT = var.environment
  }
}
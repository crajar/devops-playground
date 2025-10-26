variable "enable_datadog_agent" {}
variable "launch_type" {}
variable "advanced_container_definition" {}
variable "containers" {
  type = list(object({
    name = string
    image = string
    http_port = number
    cpu = number
    memory = number
    env_vars = map(string)
  }))
  default = null
}

variable "cloudwatch_log_group" {}
variable "name_prefix" {}
variable "environment" {}
variable "aws_region_cd" {}
variable "service_name" {}
variable "resource_slug" {}
variable "cloudwatch_logs_aws_region" {}
variable "cloudwatch_logs_stream_prefix" {}
variable "aws_region" {}
variable "secrets" {}
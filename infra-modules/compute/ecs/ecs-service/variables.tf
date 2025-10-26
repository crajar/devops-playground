variable "enable_datadog_agent" { type = bool}
variable "launch_type" { type = string}
variable "advanced_container_definition" { type = any}
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

variable "cloudwatch_log_group" { type = string}
variable "name_prefix" { type = string}
variable "environment" { type = string}
variable "service_name" { type = string}
variable "cloudwatch_logs_aws_region" {}
variable "resource_slug" { type = string}
variable "cloudwatch_logs_stream_prefix" { type = string}
variable "aws_region" { type = string}
variable "secrets" { type = map(any)}
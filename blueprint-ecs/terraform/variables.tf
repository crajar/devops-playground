variable "advanced_container_definition" { type = any}
variable "advanced_container_definition_file_path" {
  type = string
  default = null
}
variable "aws_region" {type = string}
variable "aws_region_cd" {type = string}
variable "cloudwatch_log_group" {type = string}
variable "cloudwatch_logs_aws_region" {type = string}
variable "cloudwatch_logs_stream_prefix" {type = string}
variable "enable_datadog_agent" {type = bool}
variable "environment" {type = string}
variable "launch_type" {type = string}
variable "name_prefix" {type = string}
variable "resource_slug" {type = string}
variable "service_name" {type = string}
variable "secrets" {type = map(any)}

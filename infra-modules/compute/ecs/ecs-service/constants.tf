locals {
  datadog_agent_cpu = 256
  datadog_agent_memory = 512
#  datadog_agent_ecr_image = "public.ecs.aws/datadog/agent:7-jmx"
  datadog_agent_ecr_image = "dummy-dd-image-tag"
}
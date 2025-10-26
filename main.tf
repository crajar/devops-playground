
module "setup" {
  source = "./modules/setup"
  # my betting company
  name_prefix      = "mbc"
#  application_id   = "APM1234567"
#  application_name = "mbc"
#  team             = "mbc"
#  aws_account_id   = "975050004152"
#  account_type     = "nonprod"
  aws_region       = "us-east-1"
  aws_region_cd    = "use1"
  allowed_origins = "api.my-local-route53-zone-name"
  core_datadog_agent_host = "localhost"
  core_datadog_logs_injection_enabled = "true"
  core_datadog_profiling_enabled = "true"
  core_datadog_runtime_metrics_enabled = "true"
  core_datadog_trace_enabled = "true"
  core_datadog_trace_sample_rate = "1.0"
  core_datadog_version = "1.0.0"
  db_host = "localhost"
  db_port = "5432"
  db_secret_arn = "db_secret_arn"
  enable_datadog_agent = true
  environment = "dev"
  image_name = "992382468850.dkr.ecr.us-east-1.amazonaws.com/nestjs-sample"
  image_tag = "latest"
}

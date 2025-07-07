provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "vpc" {
  source = "./terraform/vpc"

  aws_availability_a = "eu-west-2a"
  aws_availability_b = "eu-west-2b"
  open_internet      = var.open_internet
}

module "ec2" {
  source = "./terraform/ec2"

  vpc_id_ec2      = module.vpc.vpc_id
  subnet_id_ec2   = module.vpc.subnet_id_a
  ami_uk          = "ami-01c0ed0b087735750" # Ubuntu 20.04 in eu-west-2
  type            = "t2.micro"
  open_internet   = var.open_internet
  public_key_path = var.public_key_path
}

# ---------------------------------------
# CloudWatch Log Group
# ---------------------------------------
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/epa/app"
  retention_in_days = 1
}

# ---------------------------------------
# SNS Topic for Alerts
# ---------------------------------------
resource "aws_sns_topic" "alerts" {
  name = "alerts-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "michael.caukill@sky.uk"
}

# ---------------------------------------
# CloudWatch Alarms
# ---------------------------------------
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 30
  statistic           = "Average"
  threshold           = 0.1
  alarm_description   = "CPU usage over 80%"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = module.ec2.instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "HighMemory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 0.1
  alarm_description   = "Memory usage over 80%"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = module.ec2.instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "error_logs" {
  alarm_name          = "ApplicationErrors"
  metric_name         = "IncomingLogEvents"
  namespace           = "AWS/Logs"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 100
  period              = 60
  evaluation_periods  = 1
  statistic           = "Sum"
  alarm_description   = "High rate of application error logs"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    LogGroupName = "/epa/app"
  }
}

# ---------------------------------------
# CloudWatch Dashboard
# ---------------------------------------
resource "aws_cloudwatch_dashboard" "epa_monitoring" {
  dashboard_name = "EPA-Observability"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0, y = 0, width = 12, height = 6,
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", module.ec2.instance_id]
          ],
          stat   = "Average",
          region = var.region,
          title  = "CPU Utilization"
        }
      },
      {
        type = "metric",
        x    = 0, y = 6, width = 12, height = 6,
        properties = {
          metrics = [
            ["CWAgent", "mem_used_percent", "InstanceId", module.ec2.instance_id]
          ],
          stat   = "Average",
          region = var.region,
          title  = "Memory Usage"
        }
      },
      {
        type = "metric",
        x    = 0, y = 12, width = 12, height = 6,
        properties = {
          metrics = [
            ["AWS/Logs", "IncomingLogEvents", "LogGroupName", "/epa/app"]
          ],
          stat   = "Sum",
          region = var.region,
          title  = "Application Error Logs"
        }
      }
    ]
  })
}

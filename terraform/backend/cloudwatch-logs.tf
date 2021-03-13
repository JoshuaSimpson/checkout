resource "aws_cloudwatch_log_group" "service-log-group" {
  name              = "/ecs/${var.service_name}-${var.environment}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_stream" "service-log-stream" {
  name           = "${var.service_name}-${var.environment}-log-stream"
  log_group_name = aws_cloudwatch_log_group.service-log-group.name
}
resource "aws_ecr_repository" "api" {
  name  = var.service_name
}
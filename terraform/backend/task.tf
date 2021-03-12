data "template_file" "template" {
  template = file("${path.module}/task-definitions/api.json.tpl")
  vars = {
    image = aws_ecr_repository.api.repository_url
    environment = var.environment
    service_name = var.service_name
    region = var.region
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "api"
  container_definitions = data.template_file.template.rendered
}
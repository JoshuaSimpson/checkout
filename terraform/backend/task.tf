data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_execution_role_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = [aws_ecr_repository.api.arn]
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = "api-${var.environment}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy" "task_execution_role_policy" {
  name   = "${aws_iam_role.task_execution_role.name}-policy"
  role   = aws_iam_role.task_execution_role.name
  policy = data.aws_iam_policy_document.task_execution_role_policy.json
}

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
  family                = "api-${var.environment}"
  container_definitions = data.template_file.template.rendered
}
resource "aws_lambda_function" "app" {
  for_each = {
    web = {
      handler     = "lambda_handler.wsgi_handler"
      memory_size = 1024
      timeout     = 30
    }
    runner = {
      handler     = "lambda_handler.command_handler"
      memory_size = 2048
      timeout     = 900
    }
  }

  function_name = "netbox-${each.key}"
  package_type  = "Image"
  architectures = ["x86_64"]
  image_uri     = "${var.ecr_repository_url}:${var.image_tag}"

  image_config {
    entry_point = ["/lambda_entrypoint.sh"]
    command     = [each.value.handler]
  }

  role = var.iam_role_arn

  memory_size = each.value.memory_size
  timeout     = each.value.timeout

  environment {
    variables = local.lambda_environments
  }

  tags = {
    Name      = "netbox-${each.key}"
    Component = each.key
  }
}

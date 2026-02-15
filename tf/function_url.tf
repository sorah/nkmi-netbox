resource "aws_lambda_function_url" "app" {
  function_name      = aws_lambda_function.app["web"].function_name
  authorization_type = "NONE"
}

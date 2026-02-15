output "function_url" {
  value = aws_lambda_function_url.app.function_url
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

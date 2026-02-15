locals {
  lambda_environments = merge(
    var.environments,
    {
      for key, arn in var.secrets :
      "SSM_SECRET__${key}" => arn
    },
  )
}

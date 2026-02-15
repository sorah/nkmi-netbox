variable "image_tag" {
  type        = string
  description = "Docker image SHA for Lambda"
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL"
}

variable "app_domain" {
  type        = string
  description = "Domain for CloudFront alias and x-forwarded-host"
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN (us-east-1) for CloudFront"
}

variable "iam_role_arn" {
  type        = string
  description = "IAM role ARN for Lambda functions"
}

variable "environments" {
  type        = map(string)
  default     = {}
  description = "Runtime environment variables (DB, Redis, etc.)"
}

variable "secrets" {
  type        = map(string)
  default     = {}
  description = "Secret name to SSM parameter ARN mapping"
}

# Including the variable file makes the terraform configuration more dynamic
variable "s3_bucket_name" {
  description = "S3 bucket Name"
  type        = string
  default     = "aws-cloud-resume-ankit-v2"
}

variable "iam_policy_name" {
  description = "My first terraform policy"
  type        = string
  default     = "first-terraform-iam-policy"
}

variable "iam_user_name" {
  description = "My first terraform iam user"
  type        = string
  default     = "first-terraform-user"
}

variable "dynamo_db_table_name" {
    description = "DynamoDB table name"
    type        = string
    default     = "visiter-counter"
}

variable "s3_bucket_name_lambda" {
  description = "S3 bucket Name for Lambda"
  type        = string
  default     = "aws-cloud-resume-ankit-v2-lambda"
}
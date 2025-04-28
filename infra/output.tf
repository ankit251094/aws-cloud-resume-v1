    output "output_s3_bucket_name_arn" {
    description = "ARN of S3 Bucket Created"
    value       = aws_s3_bucket.my_bucket.arn
    }

    output "output_iam_policy_name" {
    description = "Pplicy ID of IAM "
    value       = aws_iam_policy.iam_policy.policy_id
    }


    output "output_dynamo_db_table_name" {
    description = "DynamoDB table name"
    value       = aws_dynamodb_table.dynamo-visitorcounter.name
    }

    output "lambda_bucket_name" {
    description = "Lambda S3 Bucket name"
    value       = aws_s3_bucket.lambda_bucket.bucket
    }

    output "function_name" {
    description = "Name of the Lambda function."

    value = aws_lambda_function.lambda_my_func.function_name
}
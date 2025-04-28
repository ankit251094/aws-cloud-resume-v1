    #terraform{} block contains the provider terraform will use to provision infra
    terraform {
        # Store Remote State in Terraform Cloud
        # This will create a workspace in Terraform Cloud ( HCP)
        cloud {
        organization = "AWS-Terraform-Tutorial-Ankit-Pandey"

        workspaces {
        name = "learn-terraform-aws"
        }
    }
    #terraform installs the provider from terraform registry
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.16"
        }
    }
    required_version = ">= 1.2.0"
    }
    #provider block provides plugin used by terraform to create and manage resources
    provider "aws" {
    region  = "us-east-1"
    }

    #resource block defines the components of the infrastructure
    #resource block has 2 strings before the block : resource type and resource name
    #together the resource type and resource name form a unique ID for the resource
    resource "aws_s3_bucket" "my_bucket" {
        bucket = var.s3_bucket_name
    }

    #The aws_iam_policy_document data source uses HCL to generate a JSON representation of an IAM policy document. 
    #Writing the policy as a Terraform configuration has several advantages over defining your policy inline in the aws_iam_policy resource.
    data "aws_iam_policy_document" "s3_policy" {
    statement {
        actions   = ["s3:ListAllMyBuckets"]
        resources = ["arn:aws:s3:::*"]
        effect = "Allow"
    }
    statement {
        actions   = ["s3:*"]
        resources = [aws_s3_bucket.my_bucket.arn]
        effect = "Allow"
    }
    }
    resource "aws_iam_policy" "iam_policy" {
    name        = var.iam_policy_name
    policy = data.aws_iam_policy_document.s3_policy.json
    }

    resource "aws_iam_user_policy_attachment" "attachment" {
    user       = aws_iam_user.new_user.name
    policy_arn = aws_iam_policy.iam_policy.arn
    }

    resource "aws_iam_user" "new_user" {
    name = var.iam_user_name
    }


    #resource "aws_dynamodb_table" "dynamo-visitorcounter"  - Terraform creates a DynamoDB table on AWS
    #aws_dynamodb_table → tells Terraform you are creating a DynamoDB table.
    #dynamo-visitorcounter → this is just the Terraform name (internal name inside your Terraform code)
    resource "aws_dynamodb_table" "dynamo-visitorcounter" {
    name         = "visitor-counter"
    billing_mode = "PAY_PER_REQUEST"
    hash_key  = "id"

        attribute {
            name = "id"
            type = "S"
        }

    }


     resource "aws_s3_bucket" "lambda_bucket" {
        bucket = var.s3_bucket_name_lambda
    }

    #This configuration uses the archive_file data source to generate a zip archive

    data "archive_file" "lambda_my_func" {
    type = "zip"
    source_dir  = "${path.module}/lambda"
    output_path = "${path.module}/lambda.zip"
    }

    #aws_s3_object resource to upload the archive to your S3 bucket.
    resource "aws_s3_object" "lambda_my_func" {
        bucket = aws_s3_bucket.lambda_bucket.id
        key    = "lambda.zip"
        source = data.archive_file.lambda_my_func.output_path
        # File Fingerprint
        #filemd5(...) → calculates the MD5 hash (a unique ID) of a file.
        #So Terraform is creating a checksum (fingerprint) of your Lambda code .zip.
        #This helps Terraform know "if the file changes", then it needs to update/redeploy the Lambda automatically.
        etag = filemd5(data.archive_file.lambda_my_func.output_path)
    }

        #configure lambda  
        resource "aws_lambda_function" "lambda_my_func" {
        function_name = "myFunc"
        s3_bucket = aws_s3_bucket.lambda_bucket.id
        s3_key    = aws_s3_object.lambda_my_func.key
        runtime = "python3.9"
        handler = "myFunc.lambda_handler"
        timeout = 15
        memory_size = 128


        #source_code_hash attribute will change whenever you update the code contained in the archive, which lets Lambda know that there is a new version of your code available.
        source_code_hash = data.archive_file.lambda_my_func.output_base64sha256

        # a role which grants the function permission to access AWS services and resources in your account.
        role = aws_iam_role.lambda_exec.arn
    }

    #defines a log group to store log messages from your Lambda function for 3 days. 
    #By convention, Lambda stores logs in a group with the name /aws/lambda/<Function Name>.

        resource "aws_cloudwatch_log_group" "lambda_my_func" {
            name = "/aws/lambda/${aws_lambda_function.lambda_my_func.function_name}"
            retention_in_days = 3
    }
        #defines an IAM role that allows Lambda to access resources in your AWS account.
        resource "aws_iam_role" "lambda_exec" {
            name = "serverless_lambda"

            assume_role_policy = jsonencode({
                Version = "2012-10-17"
                Statement = [{
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = ""
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
                }
                ]
            })
    }
    #attaches a policy to the IAM role. 
    resource "aws_iam_role_policy_attachment" "lambda_policy" {
        role       = aws_iam_role.lambda_exec.name
        policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    }

    resource "aws_iam_role_policy_attachment" "lambda_dynamoroles" {
        role       = aws_iam_role.lambda_exec.name
        policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

    resource "aws_lambda_function_url" "my_lambda_url" {
    function_name      = aws_lambda_function.lambda_my_func.function_name
    authorization_type = "NONE"  # or "AWS_IAM" if you want auth
    }
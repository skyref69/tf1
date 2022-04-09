output "DATABASE-TEST-TERRAFORM-STREAM" {
  value = aws_dynamodb_table.DATABASE-TEST-TERRAFORM.stream_arn
}

output "DATABASENAME" {
  value = aws_dynamodb_table.DATABASE-TEST-TERRAFORM.name
}
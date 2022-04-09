output "database-test-terraform-stream" {
  value = aws_dynamodb_table.database-test-terraform.stream_arn
}
output "databasename" {
  value = aws_dynamodb_table.database-test-terraform.name
}
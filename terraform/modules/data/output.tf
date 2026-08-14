output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "db_security_group_id" {
  value = aws_security_group.rds.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.this.name
}

output "db_password" {
  value     = random_password.db.result
  sensitive = true
}

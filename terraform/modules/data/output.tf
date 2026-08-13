output "mysql_secret_arn" {
  value = aws_secretsmanager_secret.mysql.arn
}

output "mysql_endpoint" {
  value = aws_db_instance.mysql.address
}

output "postgres_secret_arn" {
  value = aws_secretsmanager_secret.postgres.arn
}

output "postgres_endpoint" {
  value = aws_db_instance.postgres.address
}

output "dynamodb_carts_table_name" {
  value = aws_dynamodb_table.carts.name
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

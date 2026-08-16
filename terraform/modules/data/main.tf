# ── RDS Security Group ────────────────────────────────────────────────────────
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow PostgreSQL from EKS nodes and VPC CIDR"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_cluster_security_group_id]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# ── RDS Subnet Group ──────────────────────────────────────────────────────────
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# ── RDS PostgreSQL Instance ───────────────────────────────────────────────────
resource "aws_db_instance" "this" {
  identifier        = "${var.project_name}-db"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = "bedrockdb"
  username = "dbadmin"
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.project_name}-db"
  }
}

# ── Random password for RDS ───────────────────────────────────────────────────
resource "random_password" "db" {
  length  = 24
  special = false
}

# ── DynamoDB Table ────────────────────────────────────────────────────────────
resource "aws_dynamodb_table" "this" {
  name         = "${var.project_name}-sessions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "session_id"

  attribute {
    name = "session_id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = {
    Name = "${var.project_name}-sessions"
  }
}

# ── AWS Budget Alert ──────────────────────────────────────────────────────────
resource "aws_budgets_budget" "this" {
  name         = "${var.project_name}-monthly-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.budget_limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_alert_email]
  }
}

resource "aws_secretsmanager_secret" "db" {
  name = "project-bedrock/mysql" # match whatever name your app pipeline expects — confirm exact string
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    host     = aws_db_instance.this.address
    username = aws_db_instance.this.username
    password = random_password.db.result
  })
}
resource "aws_secretsmanager_secret" "db_orders" {
  name = "project-bedrock/postgresql"
}

resource "aws_secretsmanager_secret_version" "db_orders" {
  secret_id = aws_secretsmanager_secret.db_orders.id
  secret_string = jsonencode({
    host     = aws_db_instance.this.address
    username = aws_db_instance.this.username
    password = random_password.db.result
  })
}
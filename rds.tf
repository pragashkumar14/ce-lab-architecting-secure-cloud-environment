# rds.tf
resource "aws_db_instance" "main" {
  identifier        = "secure-database"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "myapp"
  username = "dbadmin"
  password = random_password.db_password.result

  # Security
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.rds.arn
  vpc_security_group_ids              = [aws_security_group.database.id]
  db_subnet_group_name                = aws_db_subnet_group.main.name
  publicly_accessible                 = false
  iam_database_authentication_enabled = true

  # Backups
  backup_retention_period = 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # Deletion protection
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "secure-db-final-snapshot"

  tags = {
    Name        = "secure-database"
    Environment = "production"
  }
}

resource "aws_kms_key" "rds" {
  description             = "RDS encryption key"
  deletion_window_in_days = 30
}

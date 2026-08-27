# db-subnet-group.tf
resource "aws_db_subnet_group" "main" {
  name       = "secure-db-subnet-group"
  subnet_ids = aws_subnet.private_data[*].id

  tags = {
    Name = "secure-db-subnet-group"
  }
}

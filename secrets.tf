# secrets.tf
resource "random_password" "db_password" {
  length  = 20
  special = true
}

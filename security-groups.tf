# security-groups.tf

# ALB security group (shell)
resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = aws_vpc.secure.id
}

# App security group (shell)
resource "aws_security_group" "app" {
  name   = "app-sg"
  vpc_id = aws_vpc.secure.id
}

# Database security group (shell)
resource "aws_security_group" "database" {
  name   = "database-sg"
  vpc_id = aws_vpc.secure.id
}

# ALB ingress: HTTPS from internet
resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# ALB egress: to App on 8080
resource "aws_security_group_rule" "alb_egress_app" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.alb.id
}

# App ingress: from ALB on 8080
resource "aws_security_group_rule" "app_ingress_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.app.id
}

# App egress: to Database on 5432
resource "aws_security_group_rule" "app_egress_db" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.database.id
  security_group_id        = aws_security_group.app.id
}

# Database ingress: from App on 5432
resource "aws_security_group_rule" "db_ingress_app" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.database.id
}

# Database: no egress rule defined = no outbound internet

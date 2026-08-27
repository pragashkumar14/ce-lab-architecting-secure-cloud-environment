# vpc.tf
resource "aws_vpc" "secure" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name        = "secure-vpc"
    Environment = "production"
  }
}

# Public subnets (ALB)
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.secure.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-subnet-${count.index + 1}"
    Tier = "public"
  }
}

# Private app subnets
resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.secure.id
  cidr_block        = "10.0.${count.index + 11}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-app-subnet-${count.index + 1}"
    Tier = "private-app"
  }
}

# Private data subnets (NO internet route)
resource "aws_subnet" "private_data" {
  count             = 2
  vpc_id            = aws_vpc.secure.id
  cidr_block        = "10.0.${count.index + 21}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-data-subnet-${count.index + 1}"
    Tier = "private-data"
  }
}

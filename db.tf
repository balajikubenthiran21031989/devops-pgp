# Create a security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name = "zendrix-rds-sg"
  vpc_id      = aws_vpc.zendrix_vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.zendrix_private_subnet_1.cidr_block, aws_subnet.zendrix_private_subnet_2.cidr_block]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the RDS instance
resource "aws_db_instance" "rds_instance" {
  identifier             = "zendrix-rds"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  db_name                = "zendrixdb"
  username               = "zendrix_user"
  password               = "zendrix123"
  allocated_storage      = 20
  storage_type           = "gp2"
  storage_encrypted      = false
  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true
  allow_major_version_upgrade = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.zendrix_private_db_subnet_group.name
}

# Create a DB subnet group for the private subnet
resource "aws_db_subnet_group" "zendrix_private_db_subnet_group" {
 name        = "zendrix-private-db-subnet-group"
  description = "Subnet group for Zendrix RDS database in private subnets"

  subnet_ids = [
    aws_subnet.zendrix_private_subnet_1.id,
    aws_subnet.zendrix_private_subnet_2.id,
  ]
}
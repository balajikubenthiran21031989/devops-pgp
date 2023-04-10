# Create the EFS File System
resource "aws_efs_file_system" "zendrix_efs" {
  creation_token = "zendrix-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  tags = {
    Name = "zendrix-artifacts"
  }
}
# grant access to the EFS filesystem to an EC2 security group
resource "aws_efs_access_point" "zendrix_access_point" {
  file_system_id = aws_efs_file_system.zendrix_efs.id
  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/"
    creation_info {
      owner_uid = 1000
      owner_gid = 1000
      permissions = "755"
    }
  }

  tags = {
    Name = "zendrix-efs-access-point"
  }
}

# Create the security group for EFS mount targets
resource "aws_security_group" "zendrix_efs_mount_sg" {
  name = "zendrix-efs-sg"
  vpc_id = aws_vpc.zendrix_vpc.id

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = [aws_vpc.zendrix_vpc.cidr_block]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EFS mount target in private subnet 1
resource "aws_efs_mount_target" "zendrix_efs_mount_target_1" {
  file_system_id = aws_efs_file_system.zendrix_efs.id
  subnet_id      = aws_subnet.zendrix_private_subnet_1.id
  security_groups = [aws_security_group.zendrix_efs_mount_sg.id]
}

# Create the EFS mount target in private subnet 2
resource "aws_efs_mount_target" "zendrix_efs_mount_target_2" {
  file_system_id = aws_efs_file_system.zendrix_efs.id
  subnet_id      = aws_subnet.zendrix_private_subnet_2.id
  security_groups = [aws_security_group.zendrix_efs_mount_sg.id]
}

resource "aws_iam_policy" "zendrix_efs" {
  name        = "zendrix-efs-policy"
  description = "Policy to allow EC2 instances to access Zendrix Artifacts EFS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Effect   = "Allow"
        Resource = aws_efs_file_system.zendrix_efs.arn
      }
    ]
  })
}
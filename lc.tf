# Create EC2 instance profile
resource "aws_iam_instance_profile" "zendrix_instance_profile" {
  name = "zendrix-instance-profile"
  role = aws_iam_role.zendrix_ec2_role.name
}

# Create IAM roles and policies
resource "aws_iam_role" "zendrix_ec2_role" {
  name = "zendrix-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_launch_configuration" "zendrix_lc" {
  name                 = "zendrix-launch-configuration"
  image_id             = "ami-006e00d6ac75d2ebb"
  instance_type        = "t2.medium"
  key_name             = "CDIIT"
  security_groups = [aws_security_group.mywebserver.id]
  iam_instance_profile = aws_iam_instance_profile.zendrix_instance_profile.name
  user_data            = "${data.template_file.user_data.rendered}"
  associate_public_ip_address = false
  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/userdata.sh")
  vars = {
    efs_command = "mount -t efs ${aws_efs_file_system.zendrix_efs.dns_name}:/ /home/ubuntu/efs"
    github_link = "https://github.com/balajikubenthiran21031989/aws-devops-pgp.git"
    appspec_content = file("${path.module}/appspec.yml")
  }
}

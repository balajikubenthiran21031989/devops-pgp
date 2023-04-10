# CodeBuild source credential
resource "aws_codebuild_source_credential" "zendrix_credential" {
  auth_type     = "PERSONAL_ACCESS_TOKEN"
  server_type   = "GITHUB"
  token         = "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"
  user_name      = "balajikubenthiran21031989"
}

# CodeBuild project
resource "aws_codebuild_project" "zendrix_build_project" {
  name           = "zendrix-build-project"
  description    = "CodeBuild project for Zendrix app"
  service_role   = aws_iam_role.codebuild_role.arn
  source_version = "master"
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    # environment settings here
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    environment_variable {
      name  = "DOCKERHUB_USERNAME"
      value = "kkbalajius"
    }
    environment_variable {
      name  = "DOCKERHUB_PASSWORD"
      value = "Kingwith8@l@j!"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    # Enable privileged mode
    privileged_mode = true
  }
  source {
    type            = "GITHUB"
    location        = "https://github.com/balajikubenthiran21031989/aws-devops-pgp.git"
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
    auth {
      type     = "OAUTH"
      resource    = aws_codebuild_source_credential.zendrix_credential.arn
    }
  }
}

# IAM role for CodeBuild project
# IAM role for CodeBuild project
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_zendrix_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  # Attach PowerUserAccess managed policy
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]

  # Policy for CloudWatch Logs and S3 access
  inline_policy {
  name = "zendrix_inline_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "CloudWatchLogsPolicy"
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      },
      {
        Sid = "S3Policy"
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      },
      {
        Sid = "IAMPolicy"
        Effect = "Allow"
        Action = [
          "iam:*"
        ]
        Resource = "*"
      },
      {
        Sid = "CodeBuildPolicy"
        Effect = "Allow"
        Action = [
          "codebuild:*"
        ]
        Resource = "*"
      }
    ]
  })
 }
}

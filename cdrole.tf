resource "aws_iam_role" "codedeploy" {
  name = "zendrix-codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
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
        Resource: [
        "${aws_s3_bucket.zendrix_upload.arn}",
        "${aws_s3_bucket.zendrix_upload.arn}/*"
        ]
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
        Resource = "arn:aws:codebuild:us-east-1:674463396899:project/zendrix-build-project"
      },
      {
        Sid = "CodeDeployPolicy"
        Effect = "Allow"
        Action = [
          "codedeploy:*"
        ]
        Resource = "*"
      }
    ]
  })
 }
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy.name
}


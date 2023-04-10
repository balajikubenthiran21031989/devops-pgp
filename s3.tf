# Create S3 bucket
resource "aws_s3_bucket" "zendrix_upload" {
  bucket = "zendrix-upload"
  tags = {
    Name = "zendrix-upload"
  }
}

# Apply server-side encryption configuration to S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "zendrix_upload" {
  bucket = aws_s3_bucket.zendrix_upload.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create IAM policy to allow users to upload files to S3 bucket
resource "aws_iam_policy" "zendrix_s3_upload" {
  name        = "zendrix-s3-upload"
  description = "Policy to allow users to upload files to Zendrix S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.zendrix_upload.arn,
          "${aws_s3_bucket.zendrix_upload.arn}/*"
        ]
      },
    ]
  })
}

# Create role for s3 bucket
resource "aws_iam_role" "zendrix_role" {
  name = "zendrix-role"

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

resource "aws_iam_role_policy_attachment" "zendrix_role_policy_attachment" {
  policy_arn = aws_iam_policy.zendrix_s3_upload.arn
  role       = aws_iam_role.zendrix_role.name
}

# Add a bucket policy to allow public access to the bucket
resource "aws_s3_bucket_policy" "zendrix_upload" {
  bucket = aws_s3_bucket.zendrix_upload.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:Put*",
          "s3:Delete*"
        ],
        Resource = [
          "${aws_s3_bucket.zendrix_upload.arn}/*"
        ]
      }
    ]
  })
}

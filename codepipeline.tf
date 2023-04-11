resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
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


resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
  role       = aws_iam_role.codepipeline_role.name
}

# create a CodePipeline
resource "aws_codepipeline" "zendrix_pipeline" {
  name     = "zendrix-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.zendrix_upload.bucket
    type     = "S3"
  }


  stage {
    name = "Source"

      action {
      name            = "Source"
      category        = "Source"
      owner           = "ThirdParty"
      provider        = "GitHub"
      version         = "1" # Update the version to 2
      output_artifacts = ["artifacts"]
      configuration = {
        Owner               = "balajikubenthiran21031989"
        Repo                = "devops-pgp"
        Branch              = "master"
        OAuthToken           = "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"
        PollForSourceChanges = "true" 
       }
    }
}

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["artifacts"]
      configuration   = {
        ProjectName = aws_codebuild_project.zendrix_build_project.name
      }
        run_order = 2
    }
  }
  

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["artifacts"]
      configuration   = {
        ApplicationName    = aws_codedeploy_app.zendrix_codedeploy_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.zendrix_codedeploy_deployment_group.deployment_group_name
      }
    }
  }
}


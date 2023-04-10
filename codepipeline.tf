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
      output_artifacts = ["source_artifact"]
      configuration = {
        Owner               = "balajikubenthiran21031989"
        Repo                = "aws-devops-pgp"
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
      input_artifacts = ["source_artifact"]
      output_artifacts = ["build_artifact"]
      configuration   = {
        ProjectName = aws_codebuild_project.zendrix_build_project.name
      }
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
      input_artifacts = ["build_artifact"]
      configuration   = {
        ApplicationName    = aws_codedeploy_app.zendrix_codedeploy_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.zendrix_codedeploy_deployment_group.deployment_group_name
      }
    }
  }
}


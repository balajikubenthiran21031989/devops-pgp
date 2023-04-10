# Create an SNS topic
resource "aws_sns_topic" "zendrix_sns_topic" {
  name = "zendrix_sns_topic"
  display_name = "Zendrix SNS Topic"
}

resource "aws_sns_topic_subscription" "zendrix_sns_topic_subscription" {
  topic_arn = aws_sns_topic.zendrix_sns_topic.arn
  protocol = "email"
  endpoint = "k.k.balajius@gmail.com"
}
# CodeDeploy Application and Deployment Group Setup
resource "aws_codedeploy_app" "zendrix_codedeploy_app" {
  name = "zendrix-app"
}

resource "aws_codedeploy_deployment_group" "zendrix_codedeploy_deployment_group" {
  app_name                 = aws_codedeploy_app.zendrix_codedeploy_app.name
  service_role_arn         = aws_iam_role.codedeploy.arn
  deployment_group_name    = "zendrix-deploy-group"
  autoscaling_groups       = [aws_autoscaling_group.zendrix_asg.name]
  deployment_config_name = aws_codedeploy_deployment_config.zendrix-codedeploy-deployment-config.id
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
    }
  }
}

resource "aws_codedeploy_deployment_config" "zendrix-codedeploy-deployment-config" {
  deployment_config_name = "zendrix-codedeploy-deployment-config"

  minimum_healthy_hosts {
    type             = "HOST_COUNT"
    value            = 1
  }
}
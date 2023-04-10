resource "aws_autoscaling_policy" "zendrix_scaling_policy" {
  name                = "zendrix_scaling_policy"
  policy_type         = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.zendrix_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 80.0
  }
}

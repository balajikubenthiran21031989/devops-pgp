resource "aws_cloudwatch_metric_alarm" "zendrix_cpu_alarm" {
  alarm_name          = "zendrix-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors the CPU utilization of Zendrix instances"
  alarm_actions       = [aws_autoscaling_policy.zendrix_scaling_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.zendrix_asg.name
  }
}

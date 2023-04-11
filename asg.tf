resource "aws_autoscaling_group" "zendrix_asg" {
  name                      = "zendrix-asg"
  launch_configuration     = aws_launch_configuration.zendrix_lc.id
  vpc_zone_identifier      = [aws_subnet.zendrix_public_subnet_1.id, aws_subnet.zendrix_public_subnet_2.id]
  health_check_grace_period = 300
  min_size                  = 2
  max_size                  = 5
  desired_capacity          = 2
  health_check_type         = "EC2"
  tag {
    key                 = "Name"
    value               = "zendrix-asg"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_launch_configuration.zendrix_lc,
    aws_lb_target_group.zendrix_app_tg,
  ]

  target_group_arns = [
    aws_lb_target_group.zendrix_app_tg.arn,
  ]

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  metrics_granularity = "1Minute"
}

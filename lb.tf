resource "aws_lb" "zendrix_app_lb" {
name = "zendrix-app-lb"
load_balancer_type = "application"
subnets = [
    aws_subnet.zendrix_public_subnet_1.id,
    aws_subnet.zendrix_public_subnet_2.id
  ]
security_groups= [aws_security_group.mywebserver.id]
tags = {
Name = "zendrix-app-lb"
}
}

resource "aws_lb_target_group" "zendrix_app_tg" {
name_prefix = "zen-tg"
port = 80
protocol = "HTTP"
vpc_id = aws_vpc.zendrix_vpc.id

health_check {
healthy_threshold = 2
interval = 30
protocol = "HTTP"
timeout = 5
unhealthy_threshold = 5
path = "/"
}
}

resource "aws_lb_listener" "zendrix_app_listener" {
load_balancer_arn = aws_lb.zendrix_app_lb.arn
port = 80
protocol = "HTTP"

default_action {
type = "forward"
target_group_arn = aws_lb_target_group.zendrix_app_tg.arn
}
}
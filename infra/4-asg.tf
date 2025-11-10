resource "aws_lb_target_group" "splunkapp_tg01" {
  name        = "splunkapp-tg01"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 70
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 35
    matcher             = "200-399"
  }

  tags = {
    Name    = "splunkapp_tg01"
    Service = "TG for splunkapp"
    Owner   = "Nick"
  }
}


resource "aws_lb" "splunkapp_lb01" {
  name                       = "splunkapp-lb01"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.splunkapp_lb01_sg.id]
  subnets                    = [for i in aws_subnet.public_class_6_subnet : i.id]
  enable_deletion_protection = false
  # Lots of death and suffering here, make sure it's false

  tags = {
    Name    = "splunkapp_lb01"
    Service = "Load Balancing for Splunk ASG"
    Owner   = "Nick"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.splunkapp_lb01.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.splunkapp_tg01.arn
  }
}

data "aws_ami" "amzn-linux-2023-ecs-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-2023.*x86_64"]
  }
}

resource "aws_launch_template" "splunkapp_LT01" {
  name_prefix   = "splunkapp-LT01"
  image_id      = data.aws_ami.amzn-linux-2023-ecs-ami.id
  instance_type = "c7i-flex.large"
  user_data = filebase64("./ecs.sh")
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_role_profile.name 
  }

  vpc_security_group_ids = [aws_security_group.splunkapp_tg01_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "splunkapp_asg-instance"
      Service = "Auto Scaling"
      Owner   = "Nick"
      Planet  = "ZDR"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "splunkapp_asg01" {
  name_prefix               = "splunkapp-asg01"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 3
  vpc_zone_identifier       = [for i in aws_subnet.splunkapp_subnet : i.id]
  protect_from_scale_in     = true 
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.splunkapp_LT01.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "splunkapp_asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Purpose"
    value               = "Splunk"
    propagate_at_launch = true
  }
}
